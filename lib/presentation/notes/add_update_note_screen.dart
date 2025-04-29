import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/utils/date_utils.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/note_bloc/note_bloc.dart';

import '../../infra/common/common_widgets/app_bars/basic_app_bar.dart';
import '../../infra/common/common_widgets/buttons/PrimaryButton.dart';
import '../../infra/common/common_widgets/input_fields/TextInputFormField.dart';
import '../../infra/common/common_widgets/text_fields/CommonTextField.dart';

class AddUpdateNoteScreen extends StatefulWidget {
  final int noteBookId;
  final NoteDataModel? note;
  const AddUpdateNoteScreen({super.key, required this.noteBookId, this.note});

  @override
  State<AddUpdateNoteScreen> createState() => _AddUpdateNoteScreenState();
}

class _AddUpdateNoteScreenState extends State<AddUpdateNoteScreen> {
  final OverlayService _loadingService = OverlayService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.details ?? '');
  }

  @override
  void dispose() {
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
          content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
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
    if (_formKey.currentState!.validate()) {
      var user = HiveManager.getUserJson();
      var req = NoteDataModel(
        noteId: widget.note?.noteId ?? 0,
        noteBookId: widget.noteBookId,
        userId: user!.id!,
        title: _titleController.text,
        details: _contentController.text,
        noteBookName: 'no need for this',
        createdAt: widget.note?.createdAt ??  DateUtil.getServerFormateCurrentDateTime()
      );
      context.read<NoteBloc>().add(AddUpdateNoteEvent(req: req));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(title: widget.note == null ? "New Note" : "Update Note"),
      body: BlocListener<NoteBloc, NoteState>(
        listenWhen:
            (previous, current) => current.apiIdentifier == "add_update_note" || current.apiIdentifier == "delete_note",
        listener: (context, state) {
          if (state.apiStatus == ApiStatus.loading) {
            _loadingService.showLoadingOverlay(context);
          }
          print("state " + state.apiStatus.toString());
          if (state.apiStatus == ApiStatus.success) {
            _loadingService.hideLoadingOverlay();
            context.read<NoteBloc>().add(GetNotesEvent(req: PaginationReqModel(pageNo: 1, pageSize: 10,categoryId: widget.noteBookId)));
            Navigator.pop(context);
          }
          if (state.apiStatus == ApiStatus.error) {
            _loadingService.hideLoadingOverlay();
            ToastUtils.showError(state.resp?.message ?? ' failed');
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.mediaQueryWidth * 0.09,
          ),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.note == null ? "Enter note title here" : "Update note title",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        widget.note == null 
                            ? DateUtil.getCurrentDate() 
                            : DateUtil.getDateFromServerDate(widget.note?.createdAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.note == null 
                            ? DateUtil.getCurrentTime() 
                            : DateUtil.getTimeFromServerDate(widget.note?.createdAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        expands: false,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: widget.note == null ? "Enter your note details here" : "Update your note details",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Builder(
                    builder: (context) {
                      return Column(
                        children: [
                          PrimaryButton(
                            text: widget.note == null ? 'Save' : 'Update',
                            onTap: () => _submitNote(context)
                          ),
                          if (widget.note != null) ...[
                            SizedBox(height: 10),
                            PrimaryButton(
                              text: 'Delete',
                              bgColor: Colors.red,
                              onTap: () => _showDeleteConfirmation(context, context.read<NoteBloc>()),
                            ),
                          ],
                        ],
                      );
                    }
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
