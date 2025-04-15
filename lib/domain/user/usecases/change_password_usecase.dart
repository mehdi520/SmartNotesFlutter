import 'package:dartz/dartz.dart';
import 'package:note_book/domain/models/user/req_model/pass_change_req_model.dart';
import 'package:note_book/domain/user/contract/user_repository.dart';

class ChangePasswordUsecase {
  final UserRepository userRepository;

  ChangePasswordUsecase(this.userRepository);

  Future<Either> call(PassChangeReqModel req) async {
    return await userRepository.changePass(req);
  }
} 