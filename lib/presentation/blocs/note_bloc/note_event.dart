part of 'note_bloc.dart';


abstract class NoteEvent {}

/// Save a note. [files] are uploaded as attachments after the note is saved.
class AddUpdateNoteEvent extends NoteEvent {
  final NoteDataModel req;
  final List<PickedFileModel> files;
  AddUpdateNoteEvent({required this.req, this.files = const []});
}

/// Load exactly this page (and remember its notebook / search / page size).
class GetNotesEvent extends NoteEvent {
  final PaginationReqModel req;
  GetNotesEvent({required this.req});
}

/// New search text: goes back to page 1.
class SearchNotesEvent extends NoteEvent {
  final String search;
  SearchNotesEvent(this.search);
}

class ChangeNotesPageEvent extends NoteEvent {
  final int page;
  ChangeNotesPageEvent(this.page);
}

/// Reload the current page with the current filters (e.g. after add / edit / delete).
class RefreshNotesEvent extends NoteEvent {}

class DelNoteEvent extends NoteEvent {
  final int noteId;
  DelNoteEvent({required this.noteId});
}
