part of 'user_bloc.dart';

class UserState extends Equatable {
  final ApiStatus apiStatus;
  final BaseResponseModel? resp;
  final UserModel? user;

  const UserState({
    this.apiStatus = ApiStatus.initial,
    this.resp,
    this.user
  });

  UserState copyWith({
    ApiStatus? apiStatus,
    BaseResponseModel? resp,
    UserModel? user,
  }) {
    return UserState(
      apiStatus: apiStatus ?? this.apiStatus,
      resp: resp ?? this.resp,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [apiStatus, resp, user];
} 