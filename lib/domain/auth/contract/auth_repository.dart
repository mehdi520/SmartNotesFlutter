import 'package:dartz/dartz.dart';
import 'package:note_book/domain/models/auth_models/login_req_model.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';

abstract class AuthRepository {
  Future<Either> signup(SignUpReqModel req);
  Future<Either> signin(LoginReqModel req);
  Future<Either> getProfile();
}