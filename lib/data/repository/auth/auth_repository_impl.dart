import 'dart:io';

import 'package:dio/dio.dart';


import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/data/data_sources/remote/api_service.dart';
import 'package:note_book/domain/auth/contract/auth_repository.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
import 'package:note_book/domain/models/common_models/base_error_model.dart';

import '../../../infra/core/core_exports.dart';

class AuthRepositoryImpl extends AuthRepository {
  final ApiService _apiService;
  // final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<Either> signup(SignUpReqModel req) async {
    try {
      final httpResponse = await _apiService.signup(req: req);

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        print(httpResponse.response);
        if (httpResponse.data.status) {
          return Right(httpResponse.data);

        } else {
          return Left(
            BaseErrorModel(status: false,message: httpResponse.data.message,code: httpResponse.response.statusCode)
          );
        }
      } else {
        print(httpResponse.response);
        return Left(
            BaseErrorModel(status: false,message: httpResponse.data.message,code: httpResponse.response.statusCode)
        );
      }
    } on DioException catch (e) {
      print(e);
      return Left(
          BaseErrorModel(status: false,message: e.message,code: e.response?.statusCode != null ? e.response?.statusCode : 0)
      );
    }
  }

  @override
  Future<Either> signin(SignUpReqModel req) async {
    try {
      final httpResponse = await _apiService.signin(req: req);

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        print(httpResponse.response);
        if (httpResponse.data.status) {
          HiveManager.saveToken(httpResponse.data.access_Token!);
         // await _secureStorage.setValue(usertoken, httpResponse.data.access_Token!);
          return await getProfile();
        } else {
          return Left(
              BaseErrorModel(status: false,message: httpResponse.data.message,code: httpResponse.response.statusCode)
          );
        }
      } else {
        print(httpResponse.response);
        return Left(
            BaseErrorModel(status: false,message: httpResponse.data.message,code: httpResponse.response.statusCode)
        );
      }
    } on DioException catch (e) {
      print(e);
      return Left(
          BaseErrorModel(status: false,message: e.message,code: e.response?.statusCode != null ? e.response?.statusCode : 0)
      );
    }
  }

  @override
  Future<Either> getProfile() async {
    try {
      final httpResponse = await _apiService.getProfile();

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        print(httpResponse.response);
        if (httpResponse.data.status) {
          HiveManager.saveUserJson(httpResponse.data.data!);
          return Right(httpResponse.data);
        } else {
          return Left(
              BaseErrorModel(status: false,message: httpResponse.data.message,code: httpResponse.response.statusCode)
          );
        }
      } else {
        print(httpResponse.response);
        return Left(
            BaseErrorModel(status: false,message: httpResponse.data.message,code: httpResponse.response.statusCode)
        );
      }
    } on DioException catch (e) {
      print(e);
      return Left(
          BaseErrorModel(status: false,message: e.message,code: e.response?.statusCode != null ? e.response?.statusCode : 0)
      );
    }
  }
}
