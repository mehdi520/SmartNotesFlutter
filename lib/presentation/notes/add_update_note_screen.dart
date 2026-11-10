import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/pdf/pdf_download_helper.dart';
import 'package:note_book/infra/utils/date_utils.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/attachment_cubit/attachment_cubit.dart';
import 'package:note_book/presentation/blocs/note_bloc/note_bloc.dart';
import 'package:note_book/presentation/notes/widgets/attachments_section.dart';

import '../../infra/common/common_widgets/app_bars/basic_app_bar.dart';
import '../../infra/common/common_widgets/buttons/PrimaryButton.dart';

class AddUpdateNoteScreen extends StatefulWidget {
  final int noteBookId;
  final NoteDataModel? note;
  const AddUpdateNoteScreen({super.key, required this.noteBookId, this.note});

  @override
  State<AddUpdateNoteScreen> createState() => _AddUpdateNoteScreenState();
}

class _AddUpdateNoteScreenState extends State<AddUpdateNoteScreen> {
  final OverlayService _loadingService = OverlayService();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  /// Files picked for a new note; uploaded right after the note is saved.
  List<PickedFileModel> _pendingFiles = [];

  bool get _isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.details ?? '');
  }

  @override
  void dispose() {
    _loadingService.hideLoadingOverlay();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, NoteBloc bloc) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text(
              'Are you sure you want to delete this note and all its attachments? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                bloc.add(DelNoteEvent(noteId: widget.note!.noteId));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _submitNote(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      ToastUtils.showError('Title is required');
      return;
    }
    final user = HiveManager.getUserJson();
    final req = NoteDataModel(
      noteId: widget.note?.noteId ?? 0,
      noteBookId: widget.noteBookId,
      userId: user?.id ?? 0,
      title: _titleController.text.trim(),
      details: _contentController.text,
      createdAt: widget.note?.createdAt ?? DateUtil.getServerFormateCurrentDateTime(),
    );
    context.read<NoteBloc>().add(AddUpdateNoteEvent(req: req, files: _isEdit ? const [] : _pendingFiles));
  }

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      appBar: BasicAppBar(
        title: _isEdit ? "Update Note" : "New Note",
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Download PDF',
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () => PdfDownloadHelper.note(context, widget.note!.noteId),
            ),
        ],
      ),
      body: BlocListener<NoteBloc, NoteState>(
        listenWhen: (previous, current) =>
            current.apiIdentifier == "add_update_note" || current.apiIdentifier == "delete_note",
        listener: (context, state) {
          if (state.apiStatus == ApiStatus.loading) {
            _loadingService.showLoadingOverlay(context, progress: context.read<NoteBloc>().uploadProgress);
          }
          if (state.apiStatus == ApiStatus.success) {
            _loadingService.hideLoadingOverlay();
            final msg = state.resp?.message ?? '';
            if (msg.contains('failed')) {
              ToastUtils.showError(msg);
            } else if (msg.isNotEmpty) {
              ToastUtils.showSuccess(msg);
            }
            Navigator.pop(context);
          }
          if (state.apiStatus == ApiStatus.error) {
            _loadingService.hideLoadingOverlay();
            ToastUtils.showError(state.resp?.message ?? ' failed');
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.mediaQueryWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: _isEdit ? "Update note title" : "Enter note title here",
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _isEdit ? DateUtil.getDateFromServerDate(widget.note?.createdAt) : DateUtil.getCurrentDate(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _isEdit ? DateUtil.getTimeFromServerDate(widget.note?.createdAt) : DateUtil.getCurrentTime(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _contentController,
                            maxLines: null,
                            minLines: 6,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: _isEdit ? "Update your note details" : "Enter your note details here",
                              border: InputBorder.none,
                            ),
                          ),
                          const Divider(),
                          if (_isEdit)
                            const SavedAttachmentsSection()
                          else
                            PendingAttachmentsSection(
                              files: _pendingFiles,
                              onChanged: (files) => setState(() => _pendingFiles = files),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    return Column(
                      children: [
                        PrimaryButton(
                          text: _isEdit ? 'Update' : 'Save',
                          onTap: () => _submitNote(context),
                        ),
                        if (_isEdit) ...[
                          const SizedBox(height: 10),
                          PrimaryButton(
                            text: 'Delete',
                            bgColor: Colors.red,
                            onTap: () => _showDeleteConfirmation(context, context.read<NoteBloc>()),
                          ),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!_isEdit) return body;
    return BlocProvider(
      create: (_) => AttachmentCubit(widget.note!.noteId)..load(),
      child: body,
    );
  }
}
