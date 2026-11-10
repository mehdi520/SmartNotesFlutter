import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/infra/common/common_widgets/pagination/pagination_bar.dart';
import 'package:note_book/infra/common/common_widgets/search/app_search_field.dart';
import 'package:note_book/infra/core/core_exports.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/pdf/pdf_download_helper.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/cat_bloc/cat_bloc.dart';
import 'package:note_book/presentation/blocs/note_bloc/note_bloc.dart';
import 'package:note_book/presentation/blocs/user_bloc/user_bloc.dart';
import 'package:note_book/presentation/home/widgets/book_card.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/presentation/notes/widgets/note_card.dart';

import 'widgets/home_header.dart';

class NoteDashboardScreen extends StatelessWidget {
  final OverlayService _loadingService = OverlayService();

  NoteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CatBloc()..add(GetCatEvent(pageNo: 1))),
        // Notes search across all notebooks (only used while searching).
        BlocProvider(create: (context) => NoteBloc(categoryId: 0, pageSize: 5)),
      ],
      child: _NoteDashboardContent(
        loadingService: _loadingService,
      ),
    );
  }
}

class _NoteDashboardContent extends StatelessWidget {
  final OverlayService loadingService;


  const _NoteDashboardContent({
    required this.loadingService,
  });

  void _onSearch(BuildContext context, String text) {
    context.read<CatBloc>().add(GetCatEvent(pageNo: 1, search: text));
    if (text.isNotEmpty) {
      context.read<NoteBloc>().add(SearchNotesEvent(text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: Icon(Icons.add, size: 32),
        onPressed: () {
          final bloc = context.read<CatBloc>();
          Navigator.pushNamed(
            context,
            AppRoutes.categoryRoute,
            arguments: bloc,
          );
        },
      ),
      drawer: _navDrawer(context),
      body: SafeArea(
        child: BlocListener<CatBloc, CatState>(
          listenWhen: (previous, current) => current.apiIdentifier == "get_cat",
          listener: (context, state) {
            // Full-screen loader only for the first load; paging/search show a thin bar instead.
            if (state.apiStatus == ApiStatus.loading && !state.loaded) {
              loadingService.showLoadingOverlay(context);
            }

            if (state.apiStatus == ApiStatus.success) {
              loadingService.hideLoadingOverlay();
            }
            if (state.apiStatus == ApiStatus.error) {
              loadingService.hideLoadingOverlay();
              ToastUtils.showError(state.resp?.message ?? ' failed');
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: context.mediaQueryWidth * 0.05,
                vertical: context.mediaQueryHeight * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    final user = state.user ?? HiveManager.getUserJson();
                    return Header(userName: user?.name ?? '');
                  },
                ),
                const SizedBox(height: 16),

                AppSearchField(
                  hint: 'Search notebooks and notes',
                  onChanged: (v) => _onSearch(context, v),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: BlocBuilder<CatBloc, CatState>(
                    builder: (context, state) {
                      final searching = state.search.isNotEmpty;
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<CatBloc>().add(GetCatEvent());
                          if (searching) context.read<NoteBloc>().add(RefreshNotesEvent());
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 90),
                          children: [
                            if (!searching) ...[
                              InkWell(
                                  onTap: () => context.read<CatBloc>().add(GetCatEvent()),
                                  child: Banner()),
                              const SizedBox(height: 16),
                            ],
                            _sectionTitle(
                              searching ? 'Notebooks matching "${state.search}"' : 'Notebooks',
                              loading: state.apiStatus == ApiStatus.loading && state.loaded,
                            ),
                            if (state.loaded && state.cats.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(searching ? 'No notebooks found.' : 'No notebooks yet. Tap + to create one.',
                                    style: TextStyle(color: Colors.grey.shade600)),
                              ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.cats.length,
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 295,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.9,
                              ),
                              itemBuilder: (context, index) {
                                final book = state.cats[index];
                                return BookCard(
                                  title: book.title.toString(),
                                  fileCount: book.totalNotes.toString() + (book.totalNotes == 1 ? " Note" : " Notes"),
                                  icon: Icons.menu_book,
                                  iconColor: book.iconColor.toString(),
                                  noteBookId: book.noteBookId, cat: book,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            if (state.pageInfo.totalCount > 0)
                              PaginationBar(
                                pageInfo: state.pageInfo,
                                itemName: 'notebook',
                                itemNamePlural: 'notebooks',
                                enabled: state.apiStatus != ApiStatus.loading,
                                onPageChanged: (p) => context.read<CatBloc>().add(GetCatEvent(pageNo: p)),
                              ),
                            if (searching) ...[
                              const SizedBox(height: 24),
                              const _NoteSearchResults(),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text, {bool loading = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            if (loading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      );

  Container Banner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF6759F3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.pie_chart, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Your Smart Notes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Click here to sync your notes.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              final user = state.user ?? HiveManager.getUserJson();
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 69,
                      width: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: AppColors.primary),
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.profile_icon,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      user?.name ?? '',
                      style: TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              AppImages.profile_icon,
              height: 25,
              width: 25,
            ),
            title: Text('Profile'),
            onTap: () {
              Navigator.pushNamed(
                  context, AppRoutes.accRoute
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.menu_book,
              size: 25,
            ),
            title: Text('New Note Book'),
            onTap: () {
              // The route needs the CatBloc so the list refreshes after saving.
              final bloc = context.read<CatBloc>();
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, AppRoutes.categoryRoute, arguments: bloc);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 25,
            ),
            title: Text('Change Password'),
            onTap: () {
              Navigator.pushNamed(
                  context, AppRoutes.changepass
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: 25,
            ),
            title: Text('Logout'),
            onTap: () {
              // Clear user data and token
              HiveManager.clearUserData();

              // Clear navigation stack and go to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.loginRoute,
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// "Matching notes" on the home page: notes from all notebooks whose title or text matches.
class _NoteSearchResults extends StatelessWidget {
  const _NoteSearchResults();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        final loading = state.apiStatus == ApiStatus.loading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NoteDashboardContent._sectionTitle('Notes matching "${state.search}"', loading: loading),
            if (!state.loaded && loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.notes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('No notes found.', style: TextStyle(color: Colors.grey.shade600)),
              )
            else ...[
              ...state.notes.map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: NoteCard(
                      title: note.title ?? '',
                      category: note.noteBookName ?? '',
                      date: note.createdAt ?? '',
                      content: note.details ?? '',
                      attachmentCount: note.attachmentCount,
                      onDownload: () => PdfDownloadHelper.note(context, note.noteId),
                      onTap: () async {
                        final noteBloc = context.read<NoteBloc>();
                        final catBloc = context.read<CatBloc>();
                        await Navigator.pushNamed(context, AppRoutes.addnote, arguments: {
                          'bloc': noteBloc,
                          'noteId': note.noteBookId,
                          'note': note,
                        });
                        noteBloc.add(RefreshNotesEvent());
                        catBloc.add(GetCatEvent());
                      },
                    ),
                  )),
              PaginationBar(
                pageInfo: state.pageInfo,
                enabled: !loading,
                onPageChanged: (p) => context.read<NoteBloc>().add(ChangeNotesPageEvent(p)),
              ),
            ],
          ],
        );
      },
    );
  }
}
