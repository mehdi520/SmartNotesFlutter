import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:note_book/data/data_sources/remote/api_service.dart';
import 'package:note_book/data/data_sources/remote/note_files_api.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/domain/note/contract/note_repository.dart';
import 'package:note_book/domain/models/note/resp_models/get_notes_res_model.dart';
import 'package:note_book/data/repository/api_call.dart';
import 'package:note_book/infra/network/api_error.dart';

class NoteRepositoryImpl extends NoteRepository {
  final ApiService _apiService;
  final NoteFilesApi _filesApi;

  NoteRepositoryImpl(this._apiService, this._filesApi);

  /// Note pages are cached for offline use (search results are not).
  @override
  Future<Either> getNotes(PaginationReqModel req) {
    final searching = req.search != null && req.search!.trim().isNotEmpty;
    return cachedApiCall<GetNotesResModel>(
      cacheKey: searching ? null : 'notes:${req.categoryId ?? 0}:${req.pageNo}:${req.pageSize}',
      call: () async => (await _apiService.getUserNotes(req: req)).data,
      toJson: (d) => d.toJson(),
      fromCache: GetNotesResModel.fromCache,
    );
  }

  @override
  Future<Either> addUpdateNote(NoteDataModel req) => retrofitCall(() => _apiService.addOrUpdateNote(req: req));

  @override
  Future<Either> delNote(int note_id) => retrofitCall(() => _apiService.deleteNote(noteId: note_id));

  @override
  Future<Either> getNote(int noteId) => apiCall(() => _filesApi.getNote(noteId));

  @override
  Future<Either> getNoteBookExport(int noteBookId) => apiCall(() => _filesApi.getNoteBookExport(noteBookId));

  @override
  Future<Either> getAttachments(int noteId) => apiCall(() => _filesApi.getAttachments(noteId));

  @override
  Future<Either> uploadAttachments(
    int noteId,
    List<PickedFileModel> files, {
    void Function(double progress)? onProgress,
  }) => apiCall(() => _filesApi.uploadAttachments(noteId, files, onSendProgress: _progress(onProgress)));

  @override
  Future<Either> replaceAttachment(
    int attachmentId,
    PickedFileModel file, {
    void Function(double progress)? onProgress,
  }) => apiCall(() => _filesApi.replaceAttachment(attachmentId, file, onSendProgress: _progress(onProgress)));

  static ProgressCallback? _progress(void Function(double progress)? onProgress) =>
      onProgress == null
          ? null
          : (sent, total) {
            if (total > 0) onProgress((sent / total).clamp(0.0, 1.0));
          };

  @override
  Future<Either> renameAttachment(int attachmentId, String fileName) =>
      apiCall(() => _filesApi.renameAttachment(attachmentId, fileName));

  @override
  Future<Either> deleteAttachment(int attachmentId) => apiCall(() => _filesApi.deleteAttachment(attachmentId));

  @override
  Future<Either> downloadAttachment(int attachmentId) async {
    try {
      return Right(await _filesApi.downloadAttachment(attachmentId));
    } on DioException catch (e) {
      return Left(BaseResponseModel(status: false, message: ApiError.message(e), code: e.response?.statusCode ?? 0));
    } catch (_) {
      return const Left(BaseResponseModel(status: false, message: ApiError.generic));
    }
  }
}
