import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/utils/date_utils.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/presentation/blocs/note_bloc/note_bloc.dart';
import '../../infra/common/common_widgets/app_bars/basic_app_bar.dart';
import '../../infra/core/core_exports.dart';

class NoteScreen extends StatefulWidget {
  final int noteBookId;

  NoteScreen({super.key, required this.noteBookId});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final ScrollController _scrollController = ScrollController();
  NoteBloc? _noteBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll(BuildContext context) {
    if (_noteBloc == null) return;
    
    final state = _noteBloc!.state;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !state.hasReachedMax &&
        state.apiStatus != ApiStatus.loading) {
      
      final currentPage = (state.notes.length / 10).ceil();
      final nextPage = currentPage + 1;

      if (nextPage <= state.totalPage) {
        _noteBloc!.add(GetNotesEvent(
          req: PaginationReqModel(
            pageNo: nextPage,
            pageSize: 10,
            categoryId: widget.noteBookId,
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = NoteBloc()
          ..add(GetNotesEvent(
            req: PaginationReqModel(
              pageNo: 1,
              pageSize: 10,
              categoryId: widget.noteBookId,
            ),
          ));
        _noteBloc = bloc;
        _scrollController.addListener(() => _onScroll(context));
        return bloc;
      },
      child: Scaffold(
        appBar: BasicAppBar(title: "Notes"),
        floatingActionButton: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            return FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              child: Icon(Icons.add, size: 32),
              onPressed: () {
                final bloc = context.read<NoteBloc>();
                Navigator.pushNamed(context, AppRoutes.addnote, arguments: {
                  'bloc': bloc,
                  'noteId': widget.noteBookId,
                });
              },
            );
          },
        ),
        body: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state.apiStatus == ApiStatus.loading && state.notes.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (state.notes.isEmpty) {
              return Center(child: Text('No notes found'));
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.mediaQueryWidth * 0.09,
              ),
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.only(top: 20),
                itemCount: state.notes.length + (state.hasReachedMax ? 0 : 1),
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= state.notes.length) {
                    if (state.apiStatus == ApiStatus.loading) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final note = state.notes[index];
                  return NoteCard(
                    title: note.title!,
                    category: note.noteBookName.toString(),
                    date: note.createdAt!,
                    content: note.details!,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.addnote, arguments: {
                        'bloc': _noteBloc,
                         'noteId': widget.noteBookId,
                        'note': note,
                      });
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String content;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(category,
                      style: TextStyle(color: Colors.grey.shade600)),
                  Text(
                    DateUtil.getDateFromServerDate(date),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
