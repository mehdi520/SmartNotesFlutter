
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:note_book/data/data_sources/remote/api_service.dart';
import 'package:note_book/domain/category/contract/category_repository.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';

import '../../../domain/models/common_models/base_error_model.dart';

class CategoryRepositoryImpl extends CategoryRepository {
  final ApiService _apiService;

  CategoryRepositoryImpl(this._apiService);

  @override
  Future<Either> addOrUpdateCat(CatModel req) async {
    try {
      final httpResponse = await _apiService.addOrUpdateCat(req: req);

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        print(httpResponse.response);
        if (httpResponse.data.status) {
          return Right(httpResponse.data);
        } else {
          return Left(
            BaseResponseModel(
              status: false,
              message: httpResponse.data.message,
              code: httpResponse.response.statusCode,
            ),
          );
        }
      } else {
        print(httpResponse.response);
        return Left(
          BaseResponseModel(
            status: false,
            message: httpResponse.data.message,
            code: httpResponse.response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      print(e);
      return Left(
        BaseResponseModel(
          status: false,
          message: e.message,
          code: e.response?.statusCode ?? 0,
        ),
      );
    }
  }

  @override
  Future<Either> deleteCat(int id) async {
    try {
      final httpResponse = await _apiService.deleteCat(id: id);

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        print(httpResponse.response);
        if (httpResponse.data.status) {
          return Right(httpResponse.data);
        } else {
          return Left(
            BaseResponseModel(
              status: false,
              message: httpResponse.data.message,
              code: httpResponse.response.statusCode,
            ),
          );
        }
      } else {
        print(httpResponse.response);
        return Left(
          BaseResponseModel(
            status: false,
            message: httpResponse.data.message,
            code: httpResponse.response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      print(e);
      return Left(
        BaseResponseModel(
          status: false,
          message: e.message,
          code: e.response?.statusCode ?? 0,
        ),
      );
    }
  }

  @override
  Future<Either> getCategories({int pageNo = 0, int pageSize = 10, String? search}) async {
    try {
      final httpResponse = await _apiService.getUserCats(pageNo: pageNo, pageSize: pageSize, search: search);

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        print(httpResponse.response);
        if (httpResponse.data.status) {
          return Right(httpResponse.data);
        } else {
          return Left(
            BaseResponseModel(
              status: false,
              message: httpResponse.data.message,
              code: httpResponse.response.statusCode,
            ),
          );
        }
      } else {
        print(httpResponse.response);
        return Left(
          BaseResponseModel(
            status: false,
            message: httpResponse.data.message,
            code: httpResponse.response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      print(e);
      return Left(
        BaseResponseModel(
          status: false,
          message: e.message,
          code: e.response?.statusCode ?? 0,
        ),
      );
    }
  }
}