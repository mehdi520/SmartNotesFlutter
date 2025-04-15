import 'package:dio/dio.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await HiveManager.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Handle token expiration or invalid token
      await HiveManager.deleteToken();
      // You might want to navigate to login screen here
    }
    handler.next(err);
  }
} 