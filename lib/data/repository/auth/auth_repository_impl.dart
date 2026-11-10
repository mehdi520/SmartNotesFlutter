import 'package:dartz/dartz.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/data/data_sources/remote/api_service.dart';
import 'package:note_book/data/repository/api_call.dart';
import 'package:note_book/domain/auth/contract/auth_repository.dart';
import 'package:note_book/domain/models/auth_models/login_req_model.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';

class AuthRepositoryImpl extends AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<Either> signup(SignUpReqModel req) => retrofitCall(() => _apiService.signup(req: req));

  /// Logs in, stores the token securely, then loads and caches the profile.
  @override
  Future<Either> signin(LoginReqModel req) async {
    final login = await retrofitCall(() => _apiService.signin(req: req));
    return login.fold((error) async => Left(error), (data) async {
      final token = data.access_Token;
      if (token == null || token.isEmpty) {
        return const Left(BaseResponseModel(status: false, message: 'Login failed. Please try again.'));
      }
      await HiveManager.saveToken(token);
      return getProfile();
    });
  }

  @override
  Future<Either> getProfile() async {
    final result = await retrofitCall(() => _apiService.getProfile());
    await result.fold((_) async {}, (data) async {
      if (data.data != null) await HiveManager.saveUserJson(data.data!);
    });
    return result;
  }
}
