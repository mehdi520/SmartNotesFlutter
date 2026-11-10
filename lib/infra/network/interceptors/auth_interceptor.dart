import 'package:dio/dio.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/infra/network/session_manager.dart';

/// Adds the bearer token, and logs the user out when the server says it has expired.
class AuthInterceptor extends Interceptor {
  /// Public endpoints (login, register) return 401 for wrong credentials, not for an expired session.
  static bool _isPublic(RequestOptions o) => o.path.toLowerCase().contains('api/pub/');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = HiveManager.getToken();
    if (token != null && token.isNotEmpty && !_isPublic(options)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !_isPublic(err.requestOptions)) {
      SessionManager.sessionExpired();
    }
    handler.next(err);
  }
}
