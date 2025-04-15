import 'package:json_annotation/json_annotation.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart' show BaseResponseModel;
import 'package:note_book/domain/models/user/data_model/user_model.dart' show UserModel;

part 'get_profile_res_model.g.dart';
@JsonSerializable()
class GetProfileResModel extends BaseResponseModel{
  final UserModel? data;
  GetProfileResModel({required super.status, super.message, this.data});

  factory GetProfileResModel.fromJson(Map<String, dynamic> json) => _$GetProfileResModelFromJson(json);
  Map<String, dynamic> toJson() => _$GetProfileResModelToJson(this);
}