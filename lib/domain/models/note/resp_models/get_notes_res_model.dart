import 'package:json_annotation/json_annotation.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart' show BaseResponseModel;
import 'package:note_book/domain/models/common_models/page_info.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';

part 'get_notes_res_model.g.dart';
@JsonSerializable()
class GetNotesResModel extends BaseResponseModel{
  @JsonKey(defaultValue: 1)
  final int totalPage;
  @JsonKey(defaultValue: 1)
  final int currentPage;
  @JsonKey(defaultValue: 10)
  final int pageSize;
  @JsonKey(defaultValue: 0)
  final int totalCount;
  final List<NoteDataModel>? data;

  /// Set when this came from the offline cache instead of the server.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? cachedAt;

  const GetNotesResModel({
    required super.status,
    super.message,
    this.data,
    required this.totalPage,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalCount = 0,
    this.cachedAt,
  });

  factory GetNotesResModel.fromCache(Map<String, dynamic> json, DateTime savedAt) {
    final m = GetNotesResModel.fromJson(json);
    return GetNotesResModel(
      status: m.status,
      message: m.message,
      data: m.data,
      totalPage: m.totalPage,
      currentPage: m.currentPage,
      pageSize: m.pageSize,
      totalCount: m.totalCount,
      cachedAt: savedAt,
    );
  }

  PageInfo get pageInfo => PageInfo(
      currentPage: currentPage, pageSize: pageSize, totalPage: totalPage, totalCount: totalCount);

  factory GetNotesResModel.fromJson(Map<String, dynamic> json) => _$GetNotesResModelFromJson(json);
  Map<String, dynamic> toJson() => _$GetNotesResModelToJson(this);
}

/// Response of Note/GetNote (single note with attachments).
class GetNoteResModel extends BaseResponseModel {
  final NoteDataModel? data;
  const GetNoteResModel({required super.status, super.message, this.data});

  factory GetNoteResModel.fromJson(Map<String, dynamic> json) => GetNoteResModel(
        status: json['status'] as bool? ?? false,
        message: json['message'] as String?,
        data: json['data'] == null ? null : NoteDataModel.fromJson(json['data'] as Map<String, dynamic>),
      );
}

/// Response of Note/GetNoteBookExport: the notebook and all its notes with attachments.
class GetNoteBookExportResModel extends BaseResponseModel {
  final String noteBookTitle;
  final List<NoteDataModel> data;
  const GetNoteBookExportResModel({required super.status, super.message, this.noteBookTitle = '', this.data = const []});

  factory GetNoteBookExportResModel.fromJson(Map<String, dynamic> json) => GetNoteBookExportResModel(
        status: json['status'] as bool? ?? false,
        message: json['message'] as String?,
        noteBookTitle: (json['noteBook'] as Map<String, dynamic>?)?['title'] as String? ?? '',
        data: (json['data'] as List<dynamic>? ?? [])
            .map((e) => NoteDataModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
