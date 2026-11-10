import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs requests and responses in debug builds only, with secrets hidden.
/// Release builds log nothing.
class LoggingInterceptor extends Interceptor {
  /// Body / query / header keys whose values are never printed (compared lower-case,
  /// matched when the key contains one of these words).
  static const List<String> sensitiveKeys = ['password', 'pass', 'token', 'authorization', 'secret', 'otp', 'pin'];

  /// Longer bodies (e.g. HTML error pages) are cut to keep the console readable.
  static const int maxBodyLength = 1000;

  static bool _isSensitive(String key) {
    final k = key.toLowerCase();
    return sensitiveKeys.any(k.contains);
  }

  /// Returns a copy of [value] with sensitive values replaced by '***'.
  static Object? redact(Object? value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k, _isSensitive(k.toString()) ? '***' : redact(v)));
    }
    if (value is List) return value.map(redact).toList();
    if (value is FormData) {
      return {
        'fields': {for (final f in value.fields) f.key: _isSensitive(f.key) ? '***' : f.value},
        'files': [for (final f in value.files) '${f.key}: ${f.value.filename} (${f.value.length} bytes)'],
      };
    }
    if (value is String) {
      // JSON strings can carry secrets too.
      final trimmed = value.trimLeft();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          return redact(jsonDecode(value));
        } catch (_) {}
      }
    }
    return value;
  }

  static String format(Object? value) {
    final Object? safe = value is List<int> ? '<${value.length} bytes>' : redact(value);
    final text = safe is String ? safe : _tryEncode(safe);
    return text.length <= maxBodyLength ? text : '${text.substring(0, maxBodyLength)}… (${text.length} chars)';
  }

  static String _tryEncode(Object? v) {
    try {
      return jsonEncode(v);
    } catch (_) {
      return v.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '→ ${options.method} ${options.path}'
        '${options.queryParameters.isEmpty ? '' : ' ${format(options.queryParameters)}'}',
      );
      debugPrint('  headers: ${format(options.headers)}');
      if (options.data != null) debugPrint('  body: ${format(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('← ${response.statusCode} ${response.requestOptions.path}: ${format(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✗ ${err.response?.statusCode ?? err.type.name} ${err.requestOptions.path}: '
        '${err.response != null ? format(err.response!.data) : err.message}',
      );
    }
    handler.next(err);
  }
}
