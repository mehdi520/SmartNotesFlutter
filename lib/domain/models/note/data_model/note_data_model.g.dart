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
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$NoteDataModelToJson(NoteDataModel instance) =>
    <String, dynamic>{
      'noteBookId': instance.noteBookId,
      'noteId': instance.noteId,
      'title': instance.title,
      'details': instance.details,
      'userId': instance.userId,
      'createdAt': instance.createdAt,
    };
