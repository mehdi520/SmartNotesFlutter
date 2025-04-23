part of 'cat_bloc.dart';

class CatState extends Equatable {
  final ApiStatus apiStatus;
  final BaseResponseModel? resp;
  final List<CatModel> cats;
  final String? apiIdentifier;
  final String selectedIconColor;

  const CatState({
    this.apiStatus = ApiStatus.initial,
    this.resp,
    this.cats = const [],
    this.apiIdentifier,
    this.selectedIconColor = "#9990FF"
  });

  CatState copyWith({
    ApiStatus? apiStatus,
    BaseResponseModel? resp,
    List<CatModel>? cats,
    String? apiIdentifier,
    String? selectedIconColor
  }) {
    return CatState(
      apiStatus: apiStatus ?? this.apiStatus,
      resp: resp ?? this.resp,
      cats: cats ?? this.cats,
      apiIdentifier: apiIdentifier ?? this.apiIdentifier,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor
    );
  }

  @override
  List<Object?> get props => [apiStatus, resp, cats, apiIdentifier, selectedIconColor];
}