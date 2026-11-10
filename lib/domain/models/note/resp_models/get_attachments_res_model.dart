import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_attachment_model.dart';

/// Response of GetAttachments / UploadAttachments / ReplaceAttachment.
class GetAttachmentsResModel extends BaseResponseModel {
  final List<NoteAttachmentModel> data;
  const GetAttachmentsResModel({required super.status, super.message, this.data = const []});

  factory GetAttachmentsResModel.fromJson(Map<String, dynamic> json) => GetAttachmentsResModel(
        status: json['status'] as bool? ?? false,
        message: json['message'] as String?,
        data: (json['data'] as List<dynamic>? ?? [])
            .map((e) => NoteAttachmentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
