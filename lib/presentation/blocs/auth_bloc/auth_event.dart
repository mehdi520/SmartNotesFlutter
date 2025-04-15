part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  SignUpReqModel req;

  LoginEvent({required this.req});
}

class SignupEvent extends AuthEvent {
  SignUpReqModel req;
  SignupEvent({required this.req});
}
