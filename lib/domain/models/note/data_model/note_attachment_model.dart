import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'note_attachment_model.g.dart';

@JsonSerializable()
class NoteAttachmentModel extends Equatable {
  final int attachmentId;
  final int noteId;
  final String fileName;
  /// Relative path on the server, e.g. "uploads/notes/12/abc.png".
  final String? filePath;
  final String? contentType;
  @JsonKey(defaultValue: 0)
  final int fileSize;
  @JsonKey(defaultValue: false)
  final bool isImage;
  final String? createdAt;

  const NoteAttachmentModel({
    required this.attachmentId,
    required this.noteId,
    required this.fileName,
    this.filePath,
    this.contentType,
    this.fileSize = 0,
    this.isImage = false,
    this.createdAt,
  });

  String get extension {
    final dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
  }

  String get readableSize => formatFileSize(fileSize);

  factory NoteAttachmentModel.fromJson(Map<String, dynamic> json) => _$NoteAttachmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoteAttachmentModelToJson(this);

  @override
  List<Object?> get props => [attachmentId, noteId, fileName, filePath, contentType, fileSize, isImage];
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
