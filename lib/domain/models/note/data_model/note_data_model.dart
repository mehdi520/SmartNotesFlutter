import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:note_book/domain/models/note/data_model/note_attachment_model.dart';
part 'note_data_model.g.dart';
@JsonSerializable()
class NoteDataModel extends Equatable{
  final int noteBookId;
  final int noteId;
  final String? title;
  final String? details;
  final int userId;
  final String? createdAt;
  final String? noteBookName;
  @JsonKey(defaultValue: 0)
  final int attachmentCount;
  /// Only filled by GetNote / GetNoteBookExport. Never sent back to the server.
  @JsonKey(includeToJson: false)
  final List<NoteAttachmentModel>? attachments;

  const NoteDataModel({
    required this.noteId,
    required this.noteBookId,
    this.title,
    required this.userId,
    this.details,
    this.noteBookName,
    this.createdAt,
    this.attachmentCount = 0,
    this.attachments,
  });

  factory NoteDataModel.fromJson(Map<String, dynamic> json) => _$NoteDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoteDataModelToJson(this);

  @override
  List<Object?> get props => [noteId,noteBookId,title,userId,details,createdAt,attachmentCount,attachments];
}
