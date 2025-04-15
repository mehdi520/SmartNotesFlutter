import 'dart:io';


import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/data/data_sources/remote/api_service.dart';
import 'package:note_book/domain/models/common_models/base_error_model.dart';
import 'package:note_book/domain/models/user/req_model/pass_change_req_model.dart';
import 'package:note_book/domain/models/user/req_model/update_profile_req_model.dart';
import 'package:note_book/domain/user/contract/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl(this._apiService);
  @override
  Future<Either> changePass(PassChangeReqModel req) async {
    try {
      final httpResponse = await _apiService.changePass(req: req);

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        print(httpResponse.response);
        if (httpResponse.data.status) {
          return Right(httpResponse.data);
        } else {
          return Left(
            BaseErrorModel(
              status: false,
              message: httpResponse.data.message,
              code: httpResponse.response.statusCode,
            ),
          );
        }
      } else {
        print(httpResponse.response);
        return Left(
          BaseErrorModel(
            status: false,
            message: httpResponse.data.message,
            code: httpResponse.response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      print(e);
      return Left(
        BaseErrorModel(
          status: false,
          message: e.message,
          code: e.response?.statusCode ?? 0,
        ),
      );
    }
  }

  @override
  Future<Either> getProfile() async {
    try {
      final response = await _apiService.getProfile();

      if (response.data.status) {
        return Right(response);
      } else {
        return Left(
          BaseErrorModel(
            status: false,
            message: response.data.message,
            code: 400,
          ),
        );
      }
    } on DioException catch (e) {
      print(e);
      return Left(
        BaseErrorModel(
          status: false,
          message: e.message,
          code: e.response?.statusCode ?? 0,
        ),
      );
    }
  }

  @override
  Future<Either> updateProfile(UpdateProfileReqModel req) async {
    try {
      final response = await _apiService.updateProfile(req: req);

      if (response.data.status) {
        var user = HiveManager.getUserJson()!;
        user.name = req.name;
        user.phone = req.phone;
        HiveManager.saveUserJson(user);
        return Right(response.data);
      } else {
        return Left(
          BaseErrorModel(
            status: false,
            message: response.data.message,
            code: 400,
          ),
        );
      }
    } on DioException catch (e) {
      print(e);
      return Left(
        BaseErrorModel(
          status: false,
          message: e.message,
          code: e.response?.statusCode ?? 0,
        ),
      );
    }
  }
}
