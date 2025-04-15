part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final ApiStatus apiStatus;
  final BaseResponseModel? resp;

  const AuthState({
    this.apiStatus = ApiStatus.initial,
    this.resp,
  });

  AuthState copyWith({
    BaseResponseModel? resp,
    ApiStatus? apiStatus,
  }) {
    return AuthState(
      resp: resp ?? this.resp,
      apiStatus: apiStatus ?? this.apiStatus,
    );
  }

  @override
  List<Object?> get props => [apiStatus, resp];
}
