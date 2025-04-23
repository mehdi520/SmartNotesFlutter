// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_req_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationReqModel _$PaginationReqModelFromJson(Map<String, dynamic> json) =>
    PaginationReqModel(
      pageNo: (json['pageNo'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      categoryId: (json['categoryId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaginationReqModelToJson(PaginationReqModel instance) =>
    <String, dynamic>{
      'pageNo': instance.pageNo,
      'pageSize': instance.pageSize,
      'categoryId': instance.categoryId,
    };
