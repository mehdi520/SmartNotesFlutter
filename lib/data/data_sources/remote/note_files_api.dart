import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_attachments_res_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_notes_res_model.dart';

/// Note APIs that Retrofit doesn't handle well (multipart uploads, binary downloads),
/// plus the single-note and notebook-export calls. Uses the shared Dio (auth + logging interceptors).
class NoteFilesApi {
  final Dio _dio;

  NoteFilesApi(this._dio);

  Future<GetNoteResModel> getNote(int noteId) async {
    final res = await _dio.get<Map<String, dynamic>>('api/Note/GetNote', queryParameters: {'noteId': noteId});
    return GetNoteResModel.fromJson(res.data!);
  }

  Future<GetNoteBookExportResModel> getNoteBookExport(int noteBookId) async {
    final res = await _dio.get<Map<String, dynamic>>('api/Note/GetNoteBookExport',
        queryParameters: {'noteBookId': noteBookId});
    return GetNoteBookExportResModel.fromJson(res.data!);
  }

  Future<GetAttachmentsResModel> getAttachments(int noteId) async {
    final res = await _dio.get<Map<String, dynamic>>('api/Note/GetAttachments', queryParameters: {'noteId': noteId});
    return GetAttachmentsResModel.fromJson(res.data!);
  }

  Future<GetAttachmentsResModel> uploadAttachments(int noteId, List<PickedFileModel> files,
      {ProgressCallback? onSendProgress}) async {
    final form = FormData();
    form.fields.add(MapEntry('noteId', noteId.toString()));
    for (final f in files) {
      form.files.add(MapEntry('files', MultipartFile.fromBytes(f.bytes, filename: f.name)));
    }
    final res = await _dio.post<Map<String, dynamic>>('api/Note/UploadAttachments',
        data: form, onSendProgress: onSendProgress);
    return GetAttachmentsResModel.fromJson(res.data!);
  }

  Future<GetAttachmentsResModel> replaceAttachment(int attachmentId, PickedFileModel file) async {
    final form = FormData.fromMap({
      'attachmentId': attachmentId.toString(),
      'file': MultipartFile.fromBytes(file.bytes, filename: file.name),
    });
    final res = await _dio.post<Map<String, dynamic>>('api/Note/ReplaceAttachment', data: form);
    return GetAttachmentsResModel.fromJson(res.data!);
  }

  Future<BaseResponseModel> renameAttachment(int attachmentId, String fileName) async {
    final res = await _dio.post<Map<String, dynamic>>('api/Note/RenameAttachment',
        data: {'attachmentId': attachmentId, 'fileName': fileName});
    return BaseResponseModel.fromJson(res.data!);
  }

  Future<BaseResponseModel> deleteAttachment(int attachmentId) async {
    final res = await _dio.get<Map<String, dynamic>>('api/Note/DeleteAttachment',
        queryParameters: {'attachmentId': attachmentId});
    return BaseResponseModel.fromJson(res.data!);
  }

  /// Raw bytes of an attachment (only the owner can download it).
  Future<Uint8List> downloadAttachment(int attachmentId) async {
    final res = await _dio.get<List<int>>('api/Note/DownloadAttachment',
        queryParameters: {'attachmentId': attachmentId},
        options: Options(responseType: ResponseType.bytes));
    return Uint8List.fromList(res.data ?? const []);
  }
}
