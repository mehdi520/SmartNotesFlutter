import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/note/data_model/note_attachment_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/infra/files/file_pick_helper.dart';
import 'package:note_book/infra/files/file_saver.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/attachment_cubit/attachment_cubit.dart';

import '../../../infra/core/core_exports.dart';

/// Picks files and reports any that were too large.
Future<List<PickedFileModel>> pickAttachmentFiles({bool multiple = true}) async {
  try {
    final r = await FilePickHelper.pick(multiple: multiple);
    if (r.tooLarge.isNotEmpty) {
      ToastUtils.showError('Too large (max 25 MB): ${r.tooLarge.join(', ')}');
    }
    return r.files;
  } catch (e) {
    ToastUtils.showError('Could not pick files: $e');
    return [];
  }
}

IconData attachmentIcon(String fileName) {
  final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
  switch (ext) {
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
    case 'webp':
    case 'bmp':
    case 'heic':
      return Icons.image_outlined;
    case 'pdf':
      return Icons.picture_as_pdf_outlined;
    case 'doc':
    case 'docx':
    case 'txt':
    case 'rtf':
      return Icons.description_outlined;
    case 'xls':
    case 'xlsx':
    case 'csv':
      return Icons.table_chart_outlined;
    case 'mp3':
    case 'wav':
    case 'm4a':
      return Icons.audiotrack_outlined;
    case 'mp4':
    case 'mov':
    case 'avi':
      return Icons.movie_outlined;
    case 'zip':
    case 'rar':
    case '7z':
      return Icons.folder_zip_outlined;
    default:
      return Icons.insert_drive_file_outlined;
  }
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
        TextButton.icon(
          onPressed: busy ? null : onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add files'),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String name;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool busy;

  const _Tile({required this.name, required this.subtitle, this.trailing, this.onTap, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        dense: true,
        onTap: busy ? null : onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.secondBackground,
          child: busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(attachmentIcon(name), color: AppColors.primary),
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}

/// Files picked for a note that isn't saved yet. They are uploaded right after the note is saved.
class PendingAttachmentsSection extends StatelessWidget {
  final List<PickedFileModel> files;
  final ValueChanged<List<PickedFileModel>> onChanged;

  const PendingAttachmentsSection({super.key, required this.files, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          count: files.length,
          busy: false,
          onAdd: () async {
            final picked = await pickAttachmentFiles();
            if (picked.isNotEmpty) onChanged([...files, ...picked]);
          },
        ),
        if (files.isEmpty)
          Text('No attachments. Files are uploaded when you save the note.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ...files.asMap().entries.map((e) => _Tile(
              name: e.value.name,
              subtitle: '${e.value.readableSize} · will upload on save',
              trailing: IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.close),
                onPressed: () => onChanged([...files]..removeAt(e.key)),
              ),
            )),
      ],
    );
  }
}

enum _AttachmentAction { open, download, replace, rename, delete }

/// Attachments of a saved note: add (single / multiple), open, download, replace, rename, delete.
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
                final picked = await pickAttachmentFiles();
                if (picked.isNotEmpty) await cubit.upload(picked);
              },
            ),
            if (!state.loading && state.attachments.isEmpty)
              Text('No attachments yet.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ...state.attachments.map((a) => _Tile(
                  name: a.fileName,
                  subtitle: a.readableSize,
                  busy: state.busyId == a.attachmentId,
                  onTap: () => _open(context, cubit, a),
                  trailing: PopupMenuButton<_AttachmentAction>(
                    enabled: !state.isBusy,
                    onSelected: (action) => _onAction(context, cubit, a, action),
                    itemBuilder: (_) => [
                      if (a.isImage)
                        const PopupMenuItem(value: _AttachmentAction.open, child: _MenuRow(Icons.visibility_outlined, 'View')),
                      const PopupMenuItem(value: _AttachmentAction.download, child: _MenuRow(Icons.download_outlined, 'Download')),
                      const PopupMenuItem(value: _AttachmentAction.replace, child: _MenuRow(Icons.swap_horiz, 'Replace file')),
                      const PopupMenuItem(value: _AttachmentAction.rename, child: _MenuRow(Icons.edit_outlined, 'Rename')),
                      const PopupMenuItem(
                          value: _AttachmentAction.delete,
                          child: _MenuRow(Icons.delete_outline, 'Delete', color: Colors.red)),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }

  Future<void> _onAction(BuildContext context, AttachmentCubit cubit, NoteAttachmentModel a, _AttachmentAction action) async {
    switch (action) {
      case _AttachmentAction.open:
        await _open(context, cubit, a);
      case _AttachmentAction.download:
        await _download(cubit, a);
      case _AttachmentAction.replace:
        final picked = await pickAttachmentFiles(multiple: false);
        if (picked.isNotEmpty) await cubit.replace(a, picked.first);
      case _AttachmentAction.rename:
        final name = await _askName(context, a.fileName);
        if (name != null) await cubit.rename(a, name);
      case _AttachmentAction.delete:
        final ok = await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            title: const Text('Delete attachment'),
            content: Text('Delete "${a.fileName}"? This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(d, true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (ok == true) await cubit.delete(a);
    }
  }

  /// Images open in a preview; other files are downloaded / shared.
  Future<void> _open(BuildContext context, AttachmentCubit cubit, NoteAttachmentModel a) async {
    if (!a.isImage) return _download(cubit, a);
    final bytes = await cubit.download(a);
    if (bytes == null || !context.mounted) return;
    await showDialog(
      context: context,
      builder: (d) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(a.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  tooltip: 'Download',
                  icon: const Icon(Icons.download),
                  onPressed: () => FileSaver.save(bytes, a.fileName, mimeType: a.contentType ?? 'image/*'),
                ),
                IconButton(tooltip: 'Close', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(d)),
              ]),
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.memory(bytes, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Preview not available for this image type'),
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _download(AttachmentCubit cubit, NoteAttachmentModel a) async {
    final bytes = await cubit.download(a);
    if (bytes == null) return;
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
      builder: (d) => AlertDialog(
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
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: color)),
      ]);
}
