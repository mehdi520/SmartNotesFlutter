// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatModel _$CatModelFromJson(Map<String, dynamic> json) => CatModel(
      noteBookId: (json['noteBookId'] as num).toInt(),
      title: json['title'] as String?,
      userId: (json['userId'] as num).toInt(),
      iconColor: json['iconColor'] as String?,
      totalNotes: (json['totalNotes'] as num).toInt(),
    );

Map<String, dynamic> _$CatModelToJson(CatModel instance) => <String, dynamic>{
      'noteBookId': instance.noteBookId,
      'title': instance.title,
      'iconColor': instance.iconColor,
      'userId': instance.userId,
      'totalNotes': instance.totalNotes,
    };
