part of 'cat_bloc.dart';

class CatState extends Equatable {
  final ApiStatus apiStatus;
  final BaseResponseModel? resp;
  final List<CatModel> cats;
  final String? apiIdentifier;
  final String selectedIconColor;

  /// Paging / search of the notebook list on the home page.
  final String search;
  final int pageSize;
  final PageInfo pageInfo;
  final bool loaded;

  const CatState({
    this.apiStatus = ApiStatus.initial,
    this.resp,
    this.cats = const [],
    this.apiIdentifier,
    this.selectedIconColor = "#9990FF",
    this.search = '',
    this.pageSize = 12,
    this.pageInfo = const PageInfo(pageSize: 12),
    this.loaded = false,
  });

  CatState copyWith({
    ApiStatus? apiStatus,
    BaseResponseModel? resp,
    List<CatModel>? cats,
    String? apiIdentifier,
    String? selectedIconColor,
    String? search,
    int? pageSize,
    PageInfo? pageInfo,
    bool? loaded,
  }) {
    return CatState(
      apiStatus: apiStatus ?? this.apiStatus,
      resp: resp ?? this.resp,
      cats: cats ?? this.cats,
      apiIdentifier: apiIdentifier ?? this.apiIdentifier,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      search: search ?? this.search,
      pageSize: pageSize ?? this.pageSize,
      pageInfo: pageInfo ?? this.pageInfo,
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props =>
      [apiStatus, resp, cats, apiIdentifier, selectedIconColor, search, pageSize, pageInfo, loaded];
}
