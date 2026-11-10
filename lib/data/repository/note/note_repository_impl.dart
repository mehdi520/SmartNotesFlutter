import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:note_book/data/data_sources/remote/api_service.dart';
import 'package:note_book/data/data_sources/remote/note_files_api.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/domain/note/contract/note_repository.dart';

class NoteRepositoryImpl extends NoteRepository {
  final ApiService _apiService;
  final NoteFilesApi _filesApi;

  NoteRepositoryImpl(this._apiService, this._filesApi);

  /// Runs an API call and maps it to Either: Right(response) when status == true,
  /// otherwise Left(BaseResponseModel) with the server/network message.
  Future<Either> _run<T extends BaseResponseModel>(Future<T> Function() call) async {
    try {
      final data = await call();
      if (data.status) return Right(data);
      return Left(BaseResponseModel(status: false, message: data.message));
    } on DioException catch (e) {
      return Left(_dioError(e));
    } catch (e) {
      return Left(BaseResponseModel(status: false, message: e.toString()));
    }
  }

  BaseResponseModel _dioError(DioException e) {
    final body = e.response?.data;
    final serverMessage = body is Map ? body['message']?.toString() : null;
    return BaseResponseModel(
      status: false,
      message: serverMessage ?? e.message ?? 'Network error',
      code: e.response?.statusCode ?? 0,
    );
  }

  @override
  Future<Either> getNotes(PaginationReqModel req) =>
      _run(() async => (await _apiService.getUserNotes(req: req)).data);

  @override
  Future<Either> addUpdateNote(NoteDataModel req) =>
      _run(() async => (await _apiService.addOrUpdateNote(req: req)).data);

  @override
  Future<Either> delNote(int note_id) =>
      _run(() async => (await _apiService.deleteNote(noteId: note_id)).data);

  @override
  Future<Either> getNote(int noteId) => _run(() => _filesApi.getNote(noteId));

  @override
  Future<Either> getNoteBookExport(int noteBookId) => _run(() => _filesApi.getNoteBookExport(noteBookId));

  @override
  Future<Either> getAttachments(int noteId) => _run(() => _filesApi.getAttachments(noteId));

  @override
  Future<Either> uploadAttachments(int noteId, List<PickedFileModel> files) =>
      _run(() => _filesApi.uploadAttachments(noteId, files));

  @override
  Future<Either> replaceAttachment(int attachmentId, PickedFileModel file) =>
      _run(() => _filesApi.replaceAttachment(attachmentId, file));

  @override
  Future<Either> renameAttachment(int attachmentId, String fileName) =>
      _run(() => _filesApi.renameAttachment(attachmentId, fileName));

  @override
  Future<Either> deleteAttachment(int attachmentId) => _run(() => _filesApi.deleteAttachment(attachmentId));

  @override
  Future<Either> downloadAttachment(int attachmentId) async {
    try {
      return Right(await _filesApi.downloadAttachment(attachmentId));
    } on DioException catch (e) {
      return Left(_dioError(e));
    } catch (e) {
      return Left(BaseResponseModel(status: false, message: e.toString()));
    }
  }
}
