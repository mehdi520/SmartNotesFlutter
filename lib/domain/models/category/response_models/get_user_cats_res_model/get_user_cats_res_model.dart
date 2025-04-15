import 'package:json_annotation/json_annotation.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart' show BaseResponseModel;

part 'get_user_cats_res_model.g.dart';
@JsonSerializable()
class GetUserCatsResModel extends BaseResponseModel{
  final List<CatModel>? data;
  GetUserCatsResModel({required super.status, super.message, this.data});

  factory GetUserCatsResModel.fromJson(Map<String, dynamic> json) => _$GetUserCatsResModelFromJson(json);
  Map<String, dynamic> toJson() => _$GetUserCatsResModelToJson(this);
}