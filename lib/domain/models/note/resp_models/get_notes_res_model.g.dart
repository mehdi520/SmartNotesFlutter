// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_notes_res_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetNotesResModel _$GetNotesResModelFromJson(Map<String, dynamic> json) =>
    GetNotesResModel(
      status: json['status'] as bool,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => NoteDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPage: (json['totalPage'] as num).toInt(),
    );

Map<String, dynamic> _$GetNotesResModelToJson(GetNotesResModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'totalPage': instance.totalPage,
      'data': instance.data,
    };
