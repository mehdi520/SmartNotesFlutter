import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:note_book/data/data_sources/local/offline_cache.dart';
import 'package:note_book/data/repository/api_call.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_notes_res_model.dart';
import 'package:note_book/infra/network/api_error.dart';

DioException _offline() =>
    DioException(requestOptions: RequestOptions(path: 'api/note/GetUserNotes'), type: DioExceptionType.connectionError);

GetNotesResModel _page(String title) => GetNotesResModel(
      status: true,
      totalPage: 1,
      totalCount: 1,
      data: [NoteDataModel(noteId: 1, noteBookId: 2, userId: 3, title: title)],
    );

Future<dynamic> _cached(String? key, Future<GetNotesResModel> Function() call) => cachedApiCall<GetNotesResModel>(
      cacheKey: key,
      call: call,
      toJson: (d) => d.toJson(),
      fromCache: GetNotesResModel.fromCache,
    );

void main() {
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('notes_cache_test');
    Hive.init(dir.path);
    await OfflineCache.init();
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  setUp(OfflineCache.clear);

  group('apiCall', () {
    test('status true is Right', () async {
      final r = await apiCall(() async => const BaseResponseModel(status: true, message: 'ok'));
      expect(r.isRight(), isTrue);
    });

    test('status false with HTTP 200 is Left with the server message', () async {
      final r = await apiCall(() async => const BaseResponseModel(status: false, message: 'Access denied'));
      expect(r.fold((l) => l.message, (_) => null), 'Access denied');
    });

    test('status false without a message gets the generic text', () async {
      final r = await apiCall(() async => const BaseResponseModel(status: false));
      expect(r.fold((l) => l.message, (_) => null), ApiError.generic);
    });

    test('network errors become friendly messages, not Dio text', () async {
      final r = await apiCall<BaseResponseModel>(() async => throw _offline());
      expect(r.fold((l) => l.message, (_) => null), ApiError.offline);
    });

    test('unexpected exceptions do not leak to the user', () async {
      final r = await apiCall<BaseResponseModel>(() async => throw const FormatException('bad json'));
      expect(r.fold((l) => l.message, (_) => null), ApiError.generic);
    });
  });

  group('cachedApiCall', () {
    test('serves the last good response when offline, marked with cachedAt', () async {
      final live = await _cached('notes:2:1:10', () async => _page('Saved title'));
      expect(live.fold((_) => null, (r) => (r as GetNotesResModel).cachedAt), isNull);

      final offline = await _cached('notes:2:1:10', () async => throw _offline());
      final model = offline.fold((_) => null, (r) => r as GetNotesResModel)!;
      expect(model.data!.single.title, 'Saved title');
      expect(model.cachedAt, isNotNull);
    });

    test('offline with nothing cached is a friendly error', () async {
      final r = await _cached('notes:9:1:10', () async => throw _offline());
      expect(r.fold((l) => (l as BaseResponseModel).message, (_) => null), ApiError.offline);
    });

    test('server errors are not hidden by the cache', () async {
      await _cached('notes:2:1:10', () async => _page('Saved title'));
      final options = RequestOptions(path: 'x');
      final r = await _cached(
        'notes:2:1:10',
        () async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 500),
        ),
      );
      expect(r.isLeft(), isTrue);
    });

    test('a null key never caches', () async {
      await _cached(null, () async => _page('Search result'));
      final r = await _cached(null, () async => throw _offline());
      expect(r.isLeft(), isTrue);
    });
  });
}
