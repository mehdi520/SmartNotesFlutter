
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:note_book/data/data_sources/remote/api_service.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/domain/note/contract/note_repository.dart';

class NoteRepositoryImpl extends NoteRepository {
  final ApiService _apiService;

  NoteRepositoryImpl(this._apiService);

  @override
  Future<Either> addUpdateNote(NoteDataModel req) async {
    try {
      final httpResponse = await _apiService.addOrUpdateNote(req: req);

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
  Future<Either> delNote(int note_id) async {
    try {
      final httpResponse = await _apiService.deleteNote(noteId: note_id);

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
  Future<Either> getNotes(PaginationReqModel req) async {
    try {
      final httpResponse = await _apiService.getUserNotes(req: req);

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
