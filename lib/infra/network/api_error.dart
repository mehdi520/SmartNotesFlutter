import 'package:dio/dio.dart';

/// Turns network / server failures into messages a user can understand.
class ApiError {
  ApiError._();

  static const String generic = 'Something went wrong. Please try again.';
  static const String offline = 'No internet connection. Check your connection and try again.';
  static const String timeout = 'The server is taking too long to respond. Please try again.';
  static const String serverDown = 'The server is having a problem right now. Please try again later.';
  static const String sessionExpired = 'Your session has expired. Please log in again.';

  /// True when the request never got a response (no internet, DNS, timeout...).
  static bool isOffline(Object error) {
    if (error is! DioException) return false;
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.unknown:
        return error.response == null;
      default:
        return false;
    }
  }

  static String message(Object error) {
    if (error is! DioException) return generic;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return timeout;
      case DioExceptionType.connectionError:
        return offline;
      case DioExceptionType.badCertificate:
        return 'Could not make a secure connection to the server.';
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      case DioExceptionType.unknown:
        return error.response == null ? offline : generic;
      case DioExceptionType.badResponse:
        break;
      default:
        return generic;
    }

    final code = error.response?.statusCode ?? 0;
    // Prefer the API's own message when it sent a JSON body (e.g. validation errors).
    final body = error.response?.data;
    if (code < 500 && body is Map) {
      final m = body['message']?.toString();
      if (m != null && m.trim().isNotEmpty) return m;
    }
    switch (code) {
      case 400:
        return 'Some of the information is not valid. Please check and try again.';
      case 401:
        return sessionExpired;
      case 403:
        return "You don't have permission to do that.";
      case 404:
        return 'That item could not be found. It may have been deleted.';
      case 413:
        return 'The file is too large to upload.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
    }
    if (code >= 500) return serverDown;
    return generic;
  }
}
