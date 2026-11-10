import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_book/infra/network/interceptors/logging_interceptor.dart';

void main() {
  group('LoggingInterceptor.redact', () {
    test('hides passwords and tokens in maps, at any depth', () {
      final out = LoggingInterceptor.redact({
        'email': 'a@b.com',
        'password': 'secret1',
        'profile': {'newPassword': 'x', 'name': 'Sam'},
        'access_Token': 'jwt',
      }) as Map;

      expect(out['email'], 'a@b.com');
      expect(out['password'], '***');
      expect((out['profile'] as Map)['newPassword'], '***');
      expect((out['profile'] as Map)['name'], 'Sam');
      expect(out['access_Token'], '***');
    });

    test('hides the Authorization header', () {
      final out = LoggingInterceptor.redact({'Authorization': 'Bearer abc', 'content-type': 'json'}) as Map;
      expect(out['Authorization'], '***');
      expect(out['content-type'], 'json');
    });

    test('hides secrets inside a JSON string body', () {
      final out = LoggingInterceptor.redact('{"email":"a@b.com","password":"p"}') as Map;
      expect(out['password'], '***');
      expect(out['email'], 'a@b.com');
    });

    test('summarises multipart uploads without file contents', () {
      final form = FormData.fromMap({
        'noteId': '5',
        'files': MultipartFile.fromBytes(List.filled(10, 1), filename: 'a.png'),
      });
      final out = LoggingInterceptor.redact(form) as Map;
      expect((out['fields'] as Map)['noteId'], '5');
      expect(out['files'], ['files: a.png (10 bytes)']);
    });
  });

  test('format shortens long bodies such as HTML error pages', () {
    final text = LoggingInterceptor.format('x' * 5000);
    expect(text.length, lessThan(1100));
    expect(text, contains('5000 chars'));
  });

  test('format does not dump binary downloads', () {
    expect(LoggingInterceptor.format(List<int>.filled(2048, 0)), '<2048 bytes>');
  });
}
