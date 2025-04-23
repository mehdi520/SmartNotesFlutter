part of 'note_bloc.dart';


abstract class NoteEvent {}
 class AddUpdateNoteEvent extends NoteEvent{
  final NoteDataModel req;
  AddUpdateNoteEvent({
    required this.req
});
}
 class GetNotesEvent extends NoteEvent{
 final PaginationReqModel req;
  GetNotesEvent({
  required this.req
 });
}
 class DelNoteEvent extends NoteEvent{
 final int noteId;
 DelNoteEvent({
  required this.noteId
 });
 }

