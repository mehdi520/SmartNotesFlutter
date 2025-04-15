part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final SignUpReqModel req;

  const LoginEvent({required this.req});

  @override
  List<Object> get props => [req];
}

class SignupEvent extends AuthEvent {
  final SignUpReqModel req;

  const SignupEvent({required this.req});

  @override
  List<Object> get props => [req];
}
