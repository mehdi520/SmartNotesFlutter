import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/note/usecase/note_usecase.dart';
import 'package:note_book/infra/common/common_widgets/offline_banner.dart';
import 'package:note_book/infra/di/service_locator.dart';
import 'package:note_book/infra/network/api_error.dart';
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

class _NoteScreenBody extends StatefulWidget {
  final int noteBookId;
  final String title;

  const _NoteScreenBody({required this.noteBookId, required this.title});

  @override
  State<_NoteScreenBody> createState() => _NoteScreenBodyState();
}

class _NoteScreenBodyState extends State<_NoteScreenBody> {
  /// Notes swiped away whose delete is waiting for the Undo snackbar to close.
  final Set<int> _pendingDeletes = {};
  ScaffoldMessengerState? _messenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    // Leaving the screen ends the Undo window: the snackbar's closed handler deletes the note.
    _messenger?.hideCurrentSnackBar();
    super.dispose();
  }

  Future<void> _openNote(BuildContext context, {NoteDataModel? note}) async {
    final bloc = context.read<NoteBloc>();
    await Navigator.pushNamed(
      context,
      AppRoutes.addnote,
      arguments: {'bloc': bloc, 'noteId': widget.noteBookId, if (note != null) 'note': note},
    );
    // Refresh counts / titles / attachments after coming back.
    if (!bloc.isClosed) bloc.add(RefreshNotesEvent());
  }

  /// Reloads and keeps the pull-to-refresh spinner until the list has loaded.
  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<NoteBloc>();
    bloc.add(RefreshNotesEvent());
    await bloc.stream
        .firstWhere((s) => s.apiIdentifier == 'get_notes' && s.apiStatus != ApiStatus.loading)
        .timeout(const Duration(seconds: 30), onTimeout: () => bloc.state);
  }

  void _swipeDelete(BuildContext context, NoteDataModel note) {
    final bloc = context.read<NoteBloc>();
    setState(() => _pendingDeletes.add(note.noteId));
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            content: Text('Deleted "${(note.title ?? '').isEmpty ? 'note' : note.title}"'),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'UNDO', onPressed: () {}),
          ),
        )
        .closed
        .then((reason) async {
          if (reason == SnackBarClosedReason.action) {
            if (mounted) setState(() => _pendingDeletes.remove(note.noteId));
            return;
          }
          // Call the use case directly: this may run after the screen (and its bloc) is gone.
          final Either result = await sl<NoteUsecase>().deleteNote(note.noteId);
          result.fold((error) {
            ToastUtils.showError((error as BaseResponseModel).message ?? ApiError.generic);
            if (mounted) setState(() => _pendingDeletes.remove(note.noteId));
          }, (_) {});
          if (mounted) {
            _pendingDeletes.remove(note.noteId);
            if (!bloc.isClosed) bloc.add(RefreshNotesEvent());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    return Scaffold(
      appBar: BasicAppBar(
        title: title,
        actions: [
          IconButton(
            tooltip: 'Download all notes as PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => PdfDownloadHelper.noteBook(context, widget.noteBookId),
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
                  BlocBuilder<NoteBloc, NoteState>(
                    buildWhen: (p, c) => p.cachedAt != c.cachedAt,
                    builder:
                        (context, state) => OfflineBanner(
                          cachedAt: state.cachedAt,
                          onRetry: () => context.read<NoteBloc>().add(RefreshNotesEvent()),
                        ),
                  ),
                  Expanded(
                    child: BlocBuilder<NoteBloc, NoteState>(
                      builder: (context, state) {
                        final loading = state.apiStatus == ApiStatus.loading;
                        if (!state.loaded && loading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final notes = state.notes.where((n) => !_pendingDeletes.contains(n.noteId)).toList();
                        return Stack(
                          children: [
                            RefreshIndicator(
                              onRefresh: () => _refresh(context),
                              child:
                                  notes.isEmpty
                                      ? LayoutBuilder(
                                        // Scrollable so pull-to-refresh also works on an empty list.
                                        builder:
                                            (context, c) => ListView(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              children: [
                                                SizedBox(
                                                  height: c.maxHeight,
                                                  child: Center(
                                                    child: Text(
                                                      state.search.isEmpty
                                                          ? 'No notes yet. Tap + to add one.'
                                                          : 'No notes match "${state.search}"',
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      )
                                      : ListView.separated(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.only(bottom: 12),
                                        itemCount: notes.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                                        itemBuilder: (context, index) {
                                          final note = notes[index];
                                          return Dismissible(
                                            key: ValueKey('note-${note.noteId}'),
                                            // Deleting needs the server: no swipe while showing offline data.
                                            direction:
                                                state.cachedAt == null
                                                    ? DismissDirection.endToStart
                                                    : DismissDirection.none,
                                            background: const _SwipeDeleteBackground(),
                                            onDismissed: (_) => _swipeDelete(context, note),
                                            child: NoteCard(
                                              title: note.title ?? '',
                                              category: note.noteBookName ?? '',
                                              date: note.createdAt ?? '',
                                              content: note.details ?? '',
                                              attachmentCount: note.attachmentCount,
                                              onTap: () => _openNote(context, note: note),
                                              onDownload: () => PdfDownloadHelper.note(context, note.noteId),
                                            ),
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
                    builder:
                        (context, state) => Padding(
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

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    decoration: BoxDecoration(color: const Color(0xFFE5484D), borderRadius: BorderRadius.circular(12)),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.delete_outline, color: Colors.white),
        SizedBox(width: 6),
        Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
