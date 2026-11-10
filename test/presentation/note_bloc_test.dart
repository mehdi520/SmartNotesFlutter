import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_attachments_res_model.dart';
import 'package:note_book/domain/note/usecase/note_usecase.dart';
import 'package:note_book/infra/di/service_locator.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/presentation/blocs/note_bloc/note_bloc.dart';

class _MockNoteUsecase extends Mock implements NoteUsecase {}

const _newNote = NoteDataModel(noteId: 0, noteBookId: 72, userId: 24, title: 'chaimku');

/// Typed like the real repositories (apiCall returns a typed `Either`).
Either<BaseResponseModel, BaseResponseModel> _saved() =>
    const Right(BaseResponseModel(status: true, message: 'Note saved successfully', id: 3168));

void main() {
  late _MockNoteUsecase usecase;

  setUpAll(() {
    registerFallbackValue(_newNote);
    registerFallbackValue(<PickedFileModel>[]);
  });

  setUp(() async {
    await sl.reset();
    usecase = _MockNoteUsecase();
    sl.registerSingleton<NoteUsecase>(usecase);
  });

  blocTest<NoteBloc, NoteState>(
    'saving a note shows the server success message (regression: typed Either broke getOrElse)',
    setUp: () => when(() => usecase.addOrUpdateNote(any())).thenAnswer((_) async => _saved()),
    build: NoteBloc.new,
    act: (b) => b.add(AddUpdateNoteEvent(req: _newNote)),
    expect: () => [
      isA<NoteState>().having((s) => s.apiStatus, 'status', ApiStatus.loading),
      isA<NoteState>()
          .having((s) => s.apiStatus, 'status', ApiStatus.success)
          .having((s) => s.resp?.message, 'message', 'Note saved successfully'),
      isA<NoteState>().having((s) => s.apiStatus, 'status', ApiStatus.initial),
    ],
  );

  blocTest<NoteBloc, NoteState>(
    'pending files are uploaded to the new note id returned by the server',
    setUp: () {
      when(() => usecase.addOrUpdateNote(any())).thenAnswer((_) async => _saved());
      when(() => usecase.uploadAttachments(any(), any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((_) async => const Right(GetAttachmentsResModel(status: true)));
    },
    build: NoteBloc.new,
    act: (b) => b.add(AddUpdateNoteEvent(
      req: _newNote,
      files: [PickedFileModel(name: 'a.png', bytes: Uint8List.fromList([1]))],
    )),
    skip: 1,
    expect: () => [
      isA<NoteState>().having((s) => s.apiStatus, 'status', ApiStatus.success),
      isA<NoteState>().having((s) => s.apiStatus, 'status', ApiStatus.initial),
    ],
    verify: (_) => verify(() => usecase.uploadAttachments(3168, any(), onProgress: any(named: 'onProgress'))).called(1),
  );

  blocTest<NoteBloc, NoteState>(
    'a server error is shown as an error',
    setUp: () => when(() => usecase.addOrUpdateNote(any())).thenAnswer(
        (_) async => const Left<BaseResponseModel, BaseResponseModel>(BaseResponseModel(status: false, message: 'Title is required'))),
    build: NoteBloc.new,
    act: (b) => b.add(AddUpdateNoteEvent(req: _newNote)),
    skip: 1,
    expect: () => [
      isA<NoteState>()
          .having((s) => s.apiStatus, 'status', ApiStatus.error)
          .having((s) => s.resp?.message, 'message', 'Title is required'),
    ],
  );
}
