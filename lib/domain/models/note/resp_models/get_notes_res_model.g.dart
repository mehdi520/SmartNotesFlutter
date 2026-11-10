// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_notes_res_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetNotesResModel _$GetNotesResModelFromJson(Map<String, dynamic> json) =>
    GetNotesResModel(
      status: json['status'] as bool,
      message: json['message'] as String?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NoteDataModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalPage: (json['totalPage'] as num?)?.toInt() ?? 1,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GetNotesResModelToJson(GetNotesResModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'totalPage': instance.totalPage,
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'data': instance.data,
    };
