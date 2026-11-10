import 'package:json_annotation/json_annotation.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart' show BaseResponseModel;
import 'package:note_book/domain/models/common_models/page_info.dart';

part 'get_user_cats_res_model.g.dart';
@JsonSerializable()
class GetUserCatsResModel extends BaseResponseModel{
  final List<CatModel>? data;
  @JsonKey(defaultValue: 1)
  final int currentPage;
  @JsonKey(defaultValue: 10)
  final int pageSize;
  @JsonKey(defaultValue: 1)
  final int totalPage;
  @JsonKey(defaultValue: 0)
  final int totalCount;

  /// Set when this came from the offline cache instead of the server.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? cachedAt;

  const GetUserCatsResModel({
    required super.status,
    super.message,
    this.data,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalPage = 1,
    this.totalCount = 0,
    this.cachedAt,
  });

  factory GetUserCatsResModel.fromCache(Map<String, dynamic> json, DateTime savedAt) {
    final m = GetUserCatsResModel.fromJson(json);
    return GetUserCatsResModel(
      status: m.status,
      message: m.message,
      data: m.data,
      currentPage: m.currentPage,
      pageSize: m.pageSize,
      totalPage: m.totalPage,
      totalCount: m.totalCount,
      cachedAt: savedAt,
    );
  }

  PageInfo get pageInfo => PageInfo(
      currentPage: currentPage, pageSize: pageSize, totalPage: totalPage, totalCount: totalCount);

  factory GetUserCatsResModel.fromJson(Map<String, dynamic> json) => _$GetUserCatsResModelFromJson(json);
  Map<String, dynamic> toJson() => _$GetUserCatsResModelToJson(this);
}
