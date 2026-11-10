import 'package:dartz/dartz.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';

/// Left = BaseResponseModel (error), Right = the response model.
abstract class NoteRepository {
  Future<Either> getNotes(PaginationReqModel req);
  Future<Either> getNote(int noteId);
  Future<Either> getNoteBookExport(int noteBookId);
  Future<Either> addUpdateNote(NoteDataModel req);
  Future<Either> delNote(int note_id);

  // Attachments
  Future<Either> getAttachments(int noteId);
  /// [onProgress] gets 0.0–1.0 while the files are being sent.
  Future<Either> uploadAttachments(int noteId, List<PickedFileModel> files, {void Function(double progress)? onProgress});
  Future<Either> replaceAttachment(int attachmentId, PickedFileModel file, {void Function(double progress)? onProgress});
  Future<Either> renameAttachment(int attachmentId, String fileName);
  Future<Either> deleteAttachment(int attachmentId);
  /// Right = Uint8List
  Future<Either> downloadAttachment(int attachmentId);
}
