import 'package:dartz/dartz.dart';
import 'package:note_book/domain/models/user/req_model/update_profile_req_model.dart';
import 'package:note_book/domain/user/contract/user_repository.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';

class UpdateProfileUsecase {
  final UserRepository repository;

  UpdateProfileUsecase(this.repository);

  Future<Either> call({
    required UpdateProfileReqModel params,
  }) async {
    return await repository.updateProfile(params);
  }
} 