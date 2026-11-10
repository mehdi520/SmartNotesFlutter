import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:note_book/data/data_sources/local/offline_cache.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/infra/network/api_error.dart';
import 'package:retrofit/retrofit.dart';

/// Runs an API call and maps the result in one place:
/// - Right(response) when the server answered with `status: true`
/// - Left(BaseResponseModel) with a user-friendly message otherwise: `status: false`
///   (even with HTTP 200), HTTP errors, no internet, timeouts or bad JSON.
Future<Either<BaseResponseModel, T>> apiCall<T extends BaseResponseModel>(Future<T> Function() call) async {
  try {
    final data = await call();
    if (data.status) return Right(data);
    final m = data.message?.trim() ?? '';
    return Left(BaseResponseModel(status: false, message: m.isEmpty ? ApiError.generic : m, code: data.code));
  } on DioException catch (e) {
    return Left(BaseResponseModel(status: false, message: ApiError.message(e), code: e.response?.statusCode ?? 0));
  } catch (e, st) {
    debugPrint('apiCall failed: $e\n$st');
    return Left(const BaseResponseModel(status: false, message: ApiError.generic));
  }
}

/// [apiCall] for Retrofit methods that return `HttpResponse<T>`.
Future<Either<BaseResponseModel, T>> retrofitCall<T extends BaseResponseModel>(
  Future<HttpResponse<T>> Function() call,
) => apiCall(() async => (await call()).data);

/// [apiCall] that also keeps the last good response under [cacheKey] and returns it
/// (via [fromCache]) when the device is offline. Pass a null [cacheKey] to skip caching.
Future<Either<BaseResponseModel, T>> cachedApiCall<T extends BaseResponseModel>({
  required String? cacheKey,
  required Future<T> Function() call,
  required Map<String, dynamic> Function(T data) toJson,
  required T Function(Map<String, dynamic> json, DateTime savedAt) fromCache,
}) {
  return apiCall(() async {
    try {
      final data = await call();
      if (data.status && cacheKey != null) await OfflineCache.save(cacheKey, toJson(data));
      return data;
    } on DioException catch (e) {
      final cached = cacheKey != null && ApiError.isOffline(e) ? OfflineCache.read(cacheKey) : null;
      if (cached == null) rethrow; // apiCall turns it into a friendly Left
      return fromCache(cached.json, cached.savedAt);
    }
  });
}
