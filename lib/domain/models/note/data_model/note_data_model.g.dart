// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteDataModel _$NoteDataModelFromJson(Map<String, dynamic> json) =>
    NoteDataModel(
      noteId: (json['noteId'] as num).toInt(),
      noteBookId: (json['noteBookId'] as num).toInt(),
      title: json['title'] as String?,
      userId: (json['userId'] as num).toInt(),
      details: json['details'] as String?,
      noteBookName: json['noteBookName'] as String?,
      createdAt: json['createdAt'] as String?,
      attachmentCount: (json['attachmentCount'] as num?)?.toInt() ?? 0,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map(
                (e) => NoteAttachmentModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$NoteDataModelToJson(NoteDataModel instance) =>
    <String, dynamic>{
      'noteBookId': instance.noteBookId,
      'noteId': instance.noteId,
      'title': instance.title,
      'details': instance.details,
      'userId': instance.userId,
      'createdAt': instance.createdAt,
      'noteBookName': instance.noteBookName,
      'attachmentCount': instance.attachmentCount,
    };
