import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'note_data_model.g.dart';
@JsonSerializable()
class NoteDataModel extends Equatable{
  final int noteBookId;
  final int noteId;
  final String? title;
  final String? details;
  final int userId;
  final String? createdAt;



  NoteDataModel({
    required this.noteId,
    required this.noteBookId,
    this.title,
    required this.userId,
    this.details,
    this.createdAt
  });

  factory NoteDataModel.fromJson(Map<String, dynamic> json) => _$NoteDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoteDataModelToJson(this);

  @override
  List<Object?> get props => [noteBookId,title,userId,details,createdAt];
}

