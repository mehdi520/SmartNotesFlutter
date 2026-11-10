import 'package:dartz/dartz.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/data/data_sources/remote/api_service.dart';
import 'package:note_book/data/repository/api_call.dart';
import 'package:note_book/domain/models/user/req_model/pass_change_req_model.dart';
import 'package:note_book/domain/models/user/req_model/update_profile_req_model.dart';
import 'package:note_book/domain/user/contract/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl(this._apiService);

  @override
  Future<Either> changePass(PassChangeReqModel req) => retrofitCall(() => _apiService.changePass(req: req));

  /// Loads the profile and refreshes the locally saved copy.
  @override
  Future<Either> getProfile() async {
    final result = await retrofitCall(() => _apiService.getProfile());
    await result.fold((_) async {}, (data) async {
      if (data.data != null) await HiveManager.saveUserJson(data.data!);
    });
    return result;
  }

  @override
  Future<Either> updateProfile(UpdateProfileReqModel req) async {
    final result = await retrofitCall(() => _apiService.updateProfile(req: req));
    await result.fold((_) async {}, (_) async {
      final user = HiveManager.getUserJson();
      if (user == null) return;
      user.name = req.name;
      user.phone = req.phone;
      await HiveManager.saveUserJson(user);
    });
    return result;
  }
}
