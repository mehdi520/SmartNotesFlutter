
import 'package:dartz/dartz.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/domain/note/contract/note_repository.dart';

class NoteUsecase {
  final NoteRepository _repository;

  NoteUsecase(this._repository);

  Future<Either> getNotes(PaginationReqModel req) => _repository.getNotes(req);

  Future<Either> getNote(int noteId) => _repository.getNote(noteId);

  Future<Either> getNoteBookExport(int noteBookId) => _repository.getNoteBookExport(noteBookId);

  Future<Either> addOrUpdateNote(NoteDataModel req) => _repository.addUpdateNote(req);

  Future<Either> deleteNote(int id) => _repository.delNote(id);

  Future<Either> getAttachments(int noteId) => _repository.getAttachments(noteId);

  Future<Either> uploadAttachments(int noteId, List<PickedFileModel> files,
          {void Function(double progress)? onProgress}) =>
      _repository.uploadAttachments(noteId, files, onProgress: onProgress);

  Future<Either> replaceAttachment(int attachmentId, PickedFileModel file,
          {void Function(double progress)? onProgress}) =>
      _repository.replaceAttachment(attachmentId, file, onProgress: onProgress);

  Future<Either> renameAttachment(int attachmentId, String fileName) =>
      _repository.renameAttachment(attachmentId, fileName);

  Future<Either> deleteAttachment(int attachmentId) => _repository.deleteAttachment(attachmentId);

  Future<Either> downloadAttachment(int attachmentId) => _repository.downloadAttachment(attachmentId);
}
