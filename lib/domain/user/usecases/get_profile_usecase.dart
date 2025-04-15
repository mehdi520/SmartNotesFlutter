import 'package:dartz/dartz.dart';
import 'package:note_book/domain/user/contract/user_repository.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';

class GetProfileUsecase {
  final UserRepository repository;

  GetProfileUsecase(this.repository);

  Future<Either> call() async {
    return await repository.getProfile();
  }
} 