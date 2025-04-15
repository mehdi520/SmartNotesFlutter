import 'package:dartz/dartz.dart';
import 'package:note_book/domain/models/auth_models/response_model/login/login_res_model.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';

abstract class AuthRepository {
  Future<Either> signup(SignUpReqModel req);
  Future<Either> signin(SignUpReqModel req);
  Future<Either> getProfile();
}