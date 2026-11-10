// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_attachment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteAttachmentModel _$NoteAttachmentModelFromJson(Map<String, dynamic> json) =>
    NoteAttachmentModel(
      attachmentId: (json['attachmentId'] as num).toInt(),
      noteId: (json['noteId'] as num).toInt(),
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String?,
      contentType: json['contentType'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      isImage: json['isImage'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$NoteAttachmentModelToJson(
  NoteAttachmentModel instance,
) => <String, dynamic>{
  'attachmentId': instance.attachmentId,
  'noteId': instance.noteId,
  'fileName': instance.fileName,
  'filePath': instance.filePath,
  'contentType': instance.contentType,
  'fileSize': instance.fileSize,
  'isImage': instance.isImage,
  'createdAt': instance.createdAt,
};
