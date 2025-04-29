import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'cat_model.g.dart';
@JsonSerializable()
class CatModel extends Equatable{
  final int noteBookId;
  final String? title;
  final String? iconColor;
  final int userId;
  final int totalNotes;



  CatModel({
    required this.noteBookId,
    this.title,
    required this.userId,
    this.iconColor,
    required this.totalNotes
  });

  factory CatModel.fromJson(Map<String, dynamic> json) => _$CatModelFromJson(json);
  Map<String, dynamic> toJson() => _$CatModelToJson(this);

  @override
  List<Object?> get props => [noteBookId,title,userId,iconColor];
}

