import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/note/data_model/note_attachment_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/infra/files/file_pick_helper.dart';
import 'package:note_book/infra/files/file_saver.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/attachment_cubit/attachment_cubit.dart';
import 'package:note_book/infra/files/video_thumbnail_helper.dart';
import 'package:note_book/presentation/notes/widgets/attachment_image_viewer.dart';
import 'package:note_book/presentation/notes/widgets/pdf_preview_screen.dart';

import '../../../infra/core/core_exports.dart';

/// Asks where to pick from (camera, gallery, document, any file).
Future<AttachmentSource?> showAttachmentSourceSheet(BuildContext context) {
  Widget option(AttachmentSource source, IconData icon, String title, String subtitle) => ListTile(
    leading: CircleAvatar(backgroundColor: AppColors.secondBackground, child: Icon(icon, color: AppColors.primary)),
    title: Text(title),
    subtitle: Text(subtitle),
    onTap: () => Navigator.pop(context, source),
  );

  return showModalBottomSheet<AttachmentSource>(
    context: context,
    showDragHandle: true,
    builder:
        (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Add attachment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
              option(AttachmentSource.camera, Icons.photo_camera_outlined, 'Camera', 'Take a photo'),
              option(AttachmentSource.gallery, Icons.photo_library_outlined, 'Gallery', 'Photos and videos'),
              option(
                AttachmentSource.document,
                Icons.description_outlined,
                'Document',
                'PDF, Word, Excel, PowerPoint, text',
              ),
              option(AttachmentSource.file, Icons.folder_open_outlined, 'File', 'Any file type'),
              const SizedBox(height: 8),
            ],
          ),
        ),
  );
}

/// Asks for a source, picks files and reports any that were too large.
Future<List<PickedFileModel>> pickAttachmentFiles(BuildContext context, {bool multiple = true}) async {
  final source = await showAttachmentSourceSheet(context);
  if (source == null) return [];
  try {
    final r = await FilePickHelper.pick(source: source, multiple: multiple);
    if (r.tooLarge.isNotEmpty) {
      ToastUtils.showError('Too large (max 25 MB): ${r.tooLarge.join(', ')}');
    }
    return r.files;
  } catch (e) {
    ToastUtils.showError('Could not pick files: $e');
    return [];
  }
}

/// Icon and accent color for a file type.
({IconData icon, Color color}) attachmentStyle(String fileName) {
  final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
  switch (ext) {
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
    case 'webp':
    case 'bmp':
    case 'heic':
      return (icon: Icons.image_outlined, color: const Color(0xff0EA5E9));
    case 'pdf':
      return (icon: Icons.picture_as_pdf_outlined, color: const Color(0xffE5484D));
    case 'doc':
    case 'docx':
    case 'odt':
    case 'txt':
    case 'rtf':
      return (icon: Icons.description_outlined, color: const Color(0xff2563EB));
    case 'xls':
    case 'xlsx':
    case 'ods':
    case 'csv':
      return (icon: Icons.table_chart_outlined, color: const Color(0xff16A34A));
    case 'ppt':
    case 'pptx':
    case 'odp':
      return (icon: Icons.slideshow_outlined, color: const Color(0xffEA580C));
    case 'mp3':
    case 'wav':
    case 'm4a':
    case 'aac':
      return (icon: Icons.audiotrack_outlined, color: const Color(0xff9333EA));
    case 'mp4':
    case 'mov':
    case 'avi':
    case 'mkv':
    case 'webm':
      return (icon: Icons.movie_outlined, color: const Color(0xffDB2777));
    case 'zip':
    case 'rar':
    case '7z':
      return (icon: Icons.folder_zip_outlined, color: const Color(0xffA16207));
    default:
      return (icon: Icons.insert_drive_file_outlined, color: AppColors.primary);
  }
}

IconData attachmentIcon(String fileName) => attachmentStyle(fileName).icon;

String _extensionLabel(String fileName) {
  final dot = fileName.lastIndexOf('.');
  return dot < 0 || dot == fileName.length - 1 ? 'FILE' : fileName.substring(dot + 1).toUpperCase();
}

bool _isPdf(String fileName) => fileName.toLowerCase().endsWith('.pdf');

Future<bool> _confirmDelete(BuildContext context, String fileName) async {
  final ok = await showDialog<bool>(
    context: context,
    builder:
        (d) => AlertDialog(
          title: const Text('Delete attachment'),
          content: Text('Delete "$fileName"? This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
  );
  return ok == true;
}

class _SectionHeader extends StatelessWidget {
  final int count;
  final bool busy;
  final VoidCallback? onAdd;

  const _SectionHeader({required this.count, required this.busy, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.attach_file, color: AppColors.primary, size: 20),
        const SizedBox(width: 4),
        Text('Attachments ($count)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const Spacer(),
        if (busy)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        TextButton.icon(onPressed: busy ? null : onAdd, icon: const Icon(Icons.add), label: const Text('Add')),
      ],
    );
  }
}

/// Grid used by both sections: about 3 tiles per row on a phone, more on wider screens.
class _AttachmentGrid extends StatelessWidget {
  final List<Widget> children;
  const _AttachmentGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    // A Wrap (not a GridView) so each row is as tall as its content: no fixed aspect ratio
    // that the name/size text can overflow, whatever the font or text scale.
    const spacing = 10.0;
    const maxTileWidth = 130.0;
    return LayoutBuilder(
      builder: (context, c) {
        final columns = ((c.maxWidth + spacing) / (maxTileWidth + spacing)).ceil().clamp(1, 12);
        final tileWidth = ((c.maxWidth - spacing * (columns - 1)) / columns).floorToDouble();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: spacing,
            runSpacing: 12,
            children: [for (final child in children) SizedBox(width: tileWidth, child: child)],
          ),
        );
      },
    );
  }
}

/// A square preview (image thumbnail or file-type tile) with the name and size below,
/// and an action button in the top-right corner.
class _AttachmentTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isImage;

  /// Shows a play badge on top of the preview.
  final bool isVideo;

  /// Bytes of the preview image: the image itself, or a video frame. Null = file-type tile.
  final Future<Uint8List?>? thumbnail;
  final bool busy;

  /// Upload progress (0.0–1.0) shown while [busy]; null = indeterminate.
  final double? progress;
  final VoidCallback? onTap;
  final Widget action;

  const _AttachmentTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.isImage,
    required this.action,
    this.isVideo = false,
    this.thumbnail,
    this.busy = false,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = attachmentStyle(name);
    final radius = BorderRadius.circular(14);

    Widget fileTile() => Container(
      color: style.color.withValues(alpha: 0.10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(style.icon, color: style.color, size: 34),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: style.color, borderRadius: BorderRadius.circular(6)),
            child: Text(
              _extensionLabel(name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    Widget preview;
    if (thumbnail != null) {
      preview = LayoutBuilder(
        builder: (context, c) {
          final px = (c.maxWidth * MediaQuery.devicePixelRatioOf(context)).round();
          return FutureBuilder<Uint8List?>(
            future: thumbnail,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return Container(
                  color: AppColors.secondBackground,
                  alignment: Alignment.center,
                  child: const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              final bytes = snap.data;
              if (bytes == null) return fileTile();
              final image = Image.memory(
                bytes,
                fit: BoxFit.cover,
                cacheWidth: px, // decode at tile size, not full resolution
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => fileTile(),
              );
              if (!isVideo) return image;
              return Stack(fit: StackFit.expand, children: [image, const Center(child: _PlayBadge())]);
            },
          );
        },
      );
    } else {
      preview = fileTile();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(borderRadius: radius, border: Border.all(color: AppColors.secondBackground)),
              child: InkWell(
                onTap: busy ? null : onTap,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    preview,
                    if (busy)
                      Container(
                        color: Colors.black38,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white, value: progress),
                        ),
                      ),
                    Positioned(top: 4, right: 4, child: action),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

/// Small round button that sits on top of a tile.
class _CornerButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  const _CornerButton({required this.icon, required this.tooltip, this.onPressed});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black54,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Tooltip(
        message: tooltip,
        child: Padding(padding: const EdgeInsets.all(5), child: Icon(icon, size: 16, color: Colors.white)),
      ),
    ),
  );
}

/// Files picked for a note that isn't saved yet. They are uploaded right after the note is saved.
class PendingAttachmentsSection extends StatelessWidget {
  final List<PickedFileModel> files;
  final ValueChanged<List<PickedFileModel>> onChanged;

  const PendingAttachmentsSection({super.key, required this.files, required this.onChanged});

  /// Preview frames of picked videos, made once per picked file.
  static final Expando<Future<Uint8List?>> _videoThumbs = Expando();

  static Future<Uint8List?>? _pendingThumbnail(PickedFileModel f) {
    if (f.isImage) return Future.value(f.bytes);
    if (!VideoThumbnailHelper.isSupported || !isVideoFileName(f.name)) return null;
    return _videoThumbs[f] ??= VideoThumbnailHelper.fromBytes(f.bytes, f.name);
  }

  void _openImage(BuildContext context, PickedFileModel file) {
    final images = files.where((f) => f.isImage).toList();
    var current = [...files]; // kept up to date while the viewer deletes
    AttachmentImageViewer.open(
      context,
      initialIndex: images.indexOf(file),
      items:
          images
              .map((f) => AttachmentPreviewItem(name: f.name, subtitle: f.readableSize, load: () async => f.bytes))
              .toList(),
      onDelete: (_, i) async {
        current = [...current]..remove(images[i]);
        onChanged(current);
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          count: files.length,
          busy: false,
          onAdd: () async {
            final picked = await pickAttachmentFiles(context);
            if (picked.isNotEmpty) onChanged([...files, ...picked]);
          },
        ),
        if (files.isEmpty)
          Text(
            'No attachments. Files are uploaded when you save the note.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          )
        else
          _AttachmentGrid(
            children:
                files
                    .map(
                      (f) => _AttachmentTile(
                        key: ObjectKey(f),
                        name: f.name,
                        subtitle: '${f.readableSize} · on save',
                        isImage: f.isImage,
                        isVideo: isVideoFileName(f.name),
                        thumbnail: _pendingThumbnail(f),
                        onTap:
                            _isPdf(f.name)
                                ? () => PdfPreviewScreen.open(context, fileName: f.name, load: () async => f.bytes)
                                : f.isImage
                                ? () => _openImage(context, f)
                                : null,
                        action: _CornerButton(
                          icon: Icons.close,
                          tooltip: 'Remove',
                          onPressed: () => onChanged([...files]..remove(f)),
                        ),
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }
}

enum _AttachmentAction { open, download, replace, rename, delete }

/// Attachments of a saved note: add, view, download, replace, rename, delete.
class SavedAttachmentsSection extends StatelessWidget {
  const SavedAttachmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttachmentCubit, AttachmentState>(
      listenWhen: (p, c) => p.messageId != c.messageId,
      listener: (context, state) {
        final m = state.message ?? '';
        if (m.isEmpty) return;
        state.isError ? ToastUtils.showError(m) : ToastUtils.showSuccess(m);
      },
      builder: (context, state) {
        final cubit = context.read<AttachmentCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              count: state.attachments.length,
              busy: state.loading || state.busyId == -1,
              onAdd: () async {
                final picked = await pickAttachmentFiles(context);
                if (picked.isNotEmpty) await cubit.upload(picked);
              },
            ),
            if (state.busyId == -1 && state.progress != null) _UploadProgress(value: state.progress!),
            if (state.loading && state.attachments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (state.attachments.isEmpty)
              Text('No attachments yet.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))
            else
              _AttachmentGrid(
                children:
                    state.attachments
                        .map(
                          (a) => _AttachmentTile(
                            key: ValueKey(a), // new key after replace/rename so the thumbnail reloads
                            name: a.fileName,
                            subtitle: a.readableSize,
                            isImage: a.isImage,
                            isVideo: isVideoFileName(a.fileName),
                            thumbnail: a.isImage ? cubit.thumbnailBytes(a) : cubit.videoThumbnail(a),
                            busy: state.busyId == a.attachmentId,
                            progress: state.busyId == a.attachmentId ? state.progress : null,
                            onTap: () => _open(context, cubit, a),
                            action: _menu(context, cubit, a, enabled: !state.isBusy),
                          ),
                        )
                        .toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _menu(BuildContext context, AttachmentCubit cubit, NoteAttachmentModel a, {required bool enabled}) {
    return PopupMenuButton<_AttachmentAction>(
      enabled: enabled,
      tooltip: 'More',
      padding: EdgeInsets.zero,
      onSelected: (action) => _onAction(context, cubit, a, action),
      itemBuilder:
          (_) => [
            PopupMenuItem(
              value: _AttachmentAction.open,
              child: _MenuRow(
                a.isImage || _isPdf(a.fileName) ? Icons.fullscreen : Icons.open_in_new,
                a.isImage || _isPdf(a.fileName) ? 'View' : 'Open',
              ),
            ),
            const PopupMenuItem(
              value: _AttachmentAction.download,
              child: _MenuRow(Icons.download_outlined, 'Download'),
            ),
            const PopupMenuItem(value: _AttachmentAction.replace, child: _MenuRow(Icons.swap_horiz, 'Replace file')),
            const PopupMenuItem(value: _AttachmentAction.rename, child: _MenuRow(Icons.edit_outlined, 'Rename')),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _AttachmentAction.delete,
              child: _MenuRow(Icons.delete_outline, 'Delete', color: Colors.red),
            ),
          ],
      child: const _CornerButton(icon: Icons.more_horiz, tooltip: 'More'),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    AttachmentCubit cubit,
    NoteAttachmentModel a,
    _AttachmentAction action,
  ) async {
    switch (action) {
      case _AttachmentAction.open:
        await _open(context, cubit, a);
      case _AttachmentAction.download:
        await _download(cubit, a);
      case _AttachmentAction.replace:
        final picked = await pickAttachmentFiles(context, multiple: false);
        if (picked.isNotEmpty) await cubit.replace(a, picked.first);
      case _AttachmentAction.rename:
        final name = await _askName(context, a.fileName);
        if (name != null) await cubit.rename(a, name);
      case _AttachmentAction.delete:
        if (await _confirmDelete(context, a.fileName)) await cubit.delete(a);
    }
  }

  /// Images open in the full-screen viewer (all images of the note, swipeable), PDFs in the
  /// PDF viewer; other files are downloaded / shared (so the phone opens them in the right app).
  Future<void> _open(BuildContext context, AttachmentCubit cubit, NoteAttachmentModel a) async {
    if (_isPdf(a.fileName)) {
      return PdfPreviewScreen.open(
        context,
        fileName: a.fileName,
        load: () => cubit.download(a),
        onDownload: (bytes) => _save(bytes, a),
      );
    }
    if (!a.isImage) return _download(cubit, a);
    final images = cubit.state.attachments.where((x) => x.isImage).toList();
    await AttachmentImageViewer.open(
      context,
      initialIndex: images.indexWhere((x) => x.attachmentId == a.attachmentId),
      items:
          images
              .map(
                (x) => AttachmentPreviewItem(
                  name: x.fileName,
                  subtitle: x.readableSize,
                  load: () => cubit.thumbnailBytes(x),
                ),
              )
              .toList(),
      onDownload: (i, bytes) => _save(bytes, images[i]),
      onDelete: (viewerContext, i) async {
        final target = images[i];
        if (!await _confirmDelete(viewerContext, target.fileName)) return false;
        await cubit.delete(target);
        return !cubit.state.attachments.any((x) => x.attachmentId == target.attachmentId);
      },
    );
  }

  Future<void> _download(AttachmentCubit cubit, NoteAttachmentModel a) async {
    final bytes = await cubit.download(a);
    if (bytes != null) await _save(bytes, a);
  }

  Future<void> _save(Uint8List bytes, NoteAttachmentModel a) async {
    try {
      await FileSaver.save(bytes, a.fileName, mimeType: a.contentType ?? 'application/octet-stream');
    } catch (e) {
      ToastUtils.showError('Could not save file: $e');
    }
  }

  Future<String?> _askName(BuildContext context, String current) {
    final controller = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder:
          (d) => AlertDialog(
            title: const Text('Rename attachment'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'File name'),
              onSubmitted: (v) => Navigator.pop(d, v),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(d, controller.text), child: const Text('Rename')),
            ],
          ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _MenuRow(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 10),
      Text(text, style: TextStyle(color: color)),
    ],
  );
}

/// "Uploading… 45%" bar under the attachments header.
class _UploadProgress extends StatelessWidget {
  final double value;
  const _UploadProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: value, minHeight: 6, backgroundColor: AppColors.secondBackground),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            pct >= 100 ? 'Processing…' : 'Uploading… $pct%',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
  );
}
