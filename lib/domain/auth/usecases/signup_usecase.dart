
import 'package:dartz/dartz.dart';
import 'package:note_book/domain/auth/contract/auth_repository.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
import 'package:note_book/infra/di/service_locator.dart';

class SignupUsecase {
  final AuthRepository _authRepository = sl<AuthRepository>();

  Future<Either> call({required SignUpReqModel params}) async {
    return await _authRepository.signup(params);
  }
}
