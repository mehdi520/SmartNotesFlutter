import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/infra/common/common_widgets/pagination/pagination_bar.dart';
import 'package:note_book/infra/common/common_widgets/search/app_search_field.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/pdf/pdf_download_helper.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/note_bloc/note_bloc.dart';
import 'package:note_book/presentation/notes/widgets/note_card.dart';
import '../../infra/common/common_widgets/app_bars/basic_app_bar.dart';
import '../../infra/core/core_exports.dart';

/// Notes of one notebook: search, page bar (page X of Y, total notes),
/// PDF for one note or the whole notebook.
class NoteScreen extends StatelessWidget {
  final int noteBookId;
  final String? noteBookTitle;

  const NoteScreen({super.key, required this.noteBookId, this.noteBookTitle});

  static const int pageSize = 10;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoteBloc(categoryId: noteBookId, pageSize: pageSize)..add(RefreshNotesEvent()),
      child: _NoteScreenBody(noteBookId: noteBookId, title: noteBookTitle ?? 'Notes'),
    );
  }
}

class _NoteScreenBody extends StatelessWidget {
  final int noteBookId;
  final String title;

  const _NoteScreenBody({required this.noteBookId, required this.title});

  Future<void> _openNote(BuildContext context, {NoteDataModel? note}) async {
    final bloc = context.read<NoteBloc>();
    await Navigator.pushNamed(context, AppRoutes.addnote, arguments: {
      'bloc': bloc,
      'noteId': noteBookId,
      if (note != null) 'note': note,
    });
    // Refresh counts / titles / attachments after coming back.
    bloc.add(RefreshNotesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        title: title,
        actions: [
          IconButton(
            tooltip: 'Download all notes as PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => PdfDownloadHelper.noteBook(context, noteBookId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add, size: 32),
        onPressed: () => _openNote(context),
      ),
      body: BlocListener<NoteBloc, NoteState>(
        listenWhen: (p, c) => c.apiIdentifier == "get_notes" && c.apiStatus == ApiStatus.error,
        listener: (context, state) => ToastUtils.showError(state.resp?.message ?? 'Failed to load notes'),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.mediaQueryWidth * 0.05),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  AppSearchField(
                    hint: 'Search notes in $title',
                    onChanged: (v) => context.read<NoteBloc>().add(SearchNotesEvent(v)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: BlocBuilder<NoteBloc, NoteState>(
                      builder: (context, state) {
                        final loading = state.apiStatus == ApiStatus.loading;
                        if (!state.loaded && loading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state.notes.isEmpty) {
                          return Center(
                            child: Text(
                              state.search.isEmpty ? 'No notes yet. Tap + to add one.' : 'No notes match "${state.search}"',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            RefreshIndicator(
                              onRefresh: () async => context.read<NoteBloc>().add(RefreshNotesEvent()),
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 12),
                                itemCount: state.notes.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final note = state.notes[index];
                                  return NoteCard(
                                    title: note.title ?? '',
                                    category: note.noteBookName ?? '',
                                    date: note.createdAt ?? '',
                                    content: note.details ?? '',
                                    attachmentCount: note.attachmentCount,
                                    onTap: () => _openNote(context, note: note),
                                    onDownload: () => PdfDownloadHelper.note(context, note.noteId),
                                  );
                                },
                              ),
                            ),
                            if (loading) const LinearProgressIndicator(minHeight: 2),
                          ],
                        );
                      },
                    ),
                  ),
                  BlocBuilder<NoteBloc, NoteState>(
                    buildWhen: (p, c) => p.pageInfo != c.pageInfo || p.apiStatus != c.apiStatus,
                    builder: (context, state) => Padding(
                      // leave room for the + button
                      padding: const EdgeInsets.only(top: 8, bottom: 12, right: 64),
                      child: PaginationBar(
                        pageInfo: state.pageInfo,
                        enabled: state.apiStatus != ApiStatus.loading,
                        onPageChanged: (p) => context.read<NoteBloc>().add(ChangeNotesPageEvent(p)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
