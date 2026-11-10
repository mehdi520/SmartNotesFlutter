import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_book/infra/network/api_error.dart';

DioException _http(int code, [Object? body]) {
  final options = RequestOptions(path: 'api/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: code, data: body),
  );
}

DioException _type(DioExceptionType type) => DioException(requestOptions: RequestOptions(path: 'api/x'), type: type);

void main() {
  test('no connection and timeouts are offline with plain messages', () {
    expect(ApiError.isOffline(_type(DioExceptionType.connectionError)), isTrue);
    expect(ApiError.isOffline(_type(DioExceptionType.receiveTimeout)), isTrue);
    expect(ApiError.message(_type(DioExceptionType.connectionError)), ApiError.offline);
    expect(ApiError.message(_type(DioExceptionType.connectionTimeout)), ApiError.timeout);
  });

  test('a server answer is not offline', () {
    expect(ApiError.isOffline(_http(500)), isFalse);
  });

  test('5xx (e.g. IIS 500.30 HTML page) becomes "server is having a problem"', () {
    expect(ApiError.message(_http(500, '<html>HTTP Error 500.30</html>')), ApiError.serverDown);
    expect(ApiError.message(_http(503)), ApiError.serverDown);
  });

  test("uses the API's own message for 4xx JSON errors", () {
    expect(ApiError.message(_http(400, {'message': 'Title is required'})), 'Title is required');
  });

  test('known status codes get friendly text', () {
    expect(ApiError.message(_http(401)), ApiError.sessionExpired);
    expect(ApiError.message(_http(413)), contains('too large'));
    expect(ApiError.message(_http(404)), contains('could not be found'));
  });

  test('non-network errors fall back to the generic message', () {
    expect(ApiError.message(Exception('boom')), ApiError.generic);
  });
}
