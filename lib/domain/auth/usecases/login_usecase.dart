import 'package:dartz/dartz.dart';
import 'package:note_book/domain/auth/contract/auth_repository.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';

class LoginUsecase {
  final AuthRepository _repository;

  LoginUsecase(this._repository);

  Future<Either> call(SignUpReqModel req) async {
    return await _repository.signin(req);
  }
}