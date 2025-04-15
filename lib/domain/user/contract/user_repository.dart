import 'package:dartz/dartz.dart';
import 'package:note_book/domain/models/user/req_model/pass_change_req_model.dart';
import 'package:note_book/domain/models/user/req_model/update_profile_req_model.dart';

abstract class UserRepository {
  Future<Either> updateProfile(UpdateProfileReqModel req);
  Future<Either> getProfile();
  Future<Either> changePass(PassChangeReqModel req);
}