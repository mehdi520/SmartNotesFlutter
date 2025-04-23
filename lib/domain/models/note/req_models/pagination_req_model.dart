import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'pagination_req_model.g.dart';
@JsonSerializable()
class PaginationReqModel extends Equatable{
  final int pageNo;
  final int pageSize;

  final int? categoryId;



  PaginationReqModel({
    required this.pageNo,
    required this.pageSize,
    this.categoryId,
  });

  factory PaginationReqModel.fromJson(Map<String, dynamic> json) => _$PaginationReqModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationReqModelToJson(this);

  @override
  List<Object?> get props => [pageNo,pageSize,categoryId];
}
