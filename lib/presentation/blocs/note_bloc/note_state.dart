part of 'note_bloc.dart';

class NoteState extends Equatable {
  final ApiStatus apiStatus;
  final BaseResponseModel? resp;
  final List<NoteDataModel> notes;
  final int totalPage;
  final String? apiIdentifier;
  final bool hasReachedMax;

  const NoteState({
    this.apiStatus = ApiStatus.initial,
    this.resp,
    this.notes = const [],
    this.apiIdentifier,
    this.hasReachedMax = true,
    this.totalPage = 1
  });

  NoteState copyWith({
    ApiStatus? apiStatus,
    BaseResponseModel? resp,
    List<NoteDataModel>? notes,
    String? apiIdentifier,
    bool? hasReachedMax,
    int? totalPage
  }) {
    return NoteState(
        apiStatus: apiStatus ?? this.apiStatus,
        resp: resp ?? this.resp,
        notes: notes ?? this.notes,
        apiIdentifier: apiIdentifier ?? this.apiIdentifier,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalPage: totalPage ?? this.totalPage
    );
  }

  @override
  List<Object?> get props => [apiStatus, resp, notes, apiIdentifier,hasReachedMax,totalPage];
}