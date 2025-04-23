import 'package:json_annotation/json_annotation.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart' show BaseResponseModel;
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';

part 'get_notes_res_model.g.dart';
@JsonSerializable()
class GetNotesResModel extends BaseResponseModel{
  final int totalPage;
  final List<NoteDataModel>? data;
  GetNotesResModel({required super.status, super.message, this.data,required this.totalPage});

  factory GetNotesResModel.fromJson(Map<String, dynamic> json) => _$GetNotesResModelFromJson(json);
  Map<String, dynamic> toJson() => _$GetNotesResModelToJson(this);
}