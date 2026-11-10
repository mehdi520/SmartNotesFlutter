part of 'note_bloc.dart';

class NoteState extends Equatable {
  final ApiStatus apiStatus;
  final BaseResponseModel? resp;
  final List<NoteDataModel> notes;
  final String? apiIdentifier;

  /// Current filter: notebook id (0 = all notebooks) and search text.
  final int categoryId;
  final String search;
  final int pageSize;
  final PageInfo pageInfo;

  /// True once the first page has loaded (to tell "loading" from "no results").
  final bool loaded;

  const NoteState({
    this.apiStatus = ApiStatus.initial,
    this.resp,
    this.notes = const [],
    this.apiIdentifier,
    this.categoryId = 0,
    this.search = '',
    this.pageSize = 10,
    this.pageInfo = const PageInfo(),
    this.loaded = false,
  });

  int get totalPage => pageInfo.totalPage;

  NoteState copyWith({
    ApiStatus? apiStatus,
    BaseResponseModel? resp,
    List<NoteDataModel>? notes,
    String? apiIdentifier,
    int? categoryId,
    String? search,
    int? pageSize,
    PageInfo? pageInfo,
    bool? loaded,
  }) {
    return NoteState(
      apiStatus: apiStatus ?? this.apiStatus,
      resp: resp ?? this.resp,
      notes: notes ?? this.notes,
      apiIdentifier: apiIdentifier ?? this.apiIdentifier,
      categoryId: categoryId ?? this.categoryId,
      search: search ?? this.search,
      pageSize: pageSize ?? this.pageSize,
      pageInfo: pageInfo ?? this.pageInfo,
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props =>
      [apiStatus, resp, notes, apiIdentifier, categoryId, search, pageSize, pageInfo, loaded];
}
