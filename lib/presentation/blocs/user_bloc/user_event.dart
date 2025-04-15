part of 'user_bloc.dart';


abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UpdateProfileEvent extends UserEvent {
  final UpdateProfileReqModel req;

  const UpdateProfileEvent({required this.req});

  @override
  List<Object> get props => [req];
}

class ChangePasswordEvent extends UserEvent {
  final PassChangeReqModel req;

  const ChangePasswordEvent({required this.req});

  @override
  List<Object> get props => [req];
}

class GetProfileEvent extends UserEvent {
  const GetProfileEvent();
} 