import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_attachment_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_attachments_res_model.dart';
import 'package:note_book/domain/note/usecase/note_usecase.dart';
import 'package:note_book/infra/di/service_locator.dart';
import 'package:note_book/presentation/blocs/attachment_cubit/attachment_cubit.dart';

class _MockNoteUsecase extends Mock implements NoteUsecase {}

const _photo = NoteAttachmentModel(attachmentId: 1, noteId: 7, fileName: 'a.png', isImage: true, fileSize: 10);
const _pdf = NoteAttachmentModel(attachmentId: 2, noteId: 7, fileName: 'b.pdf', fileSize: 20);
final _file = PickedFileModel(name: 'c.txt', bytes: Uint8List.fromList([1, 2, 3]));

void main() {
  late _MockNoteUsecase usecase;

  setUpAll(() => registerFallbackValue(<PickedFileModel>[]));

  setUp(() async {
    await sl.reset();
    usecase = _MockNoteUsecase();
    sl.registerSingleton<NoteUsecase>(usecase);
  });

  blocTest<AttachmentCubit, AttachmentState>(
    'load shows the note attachments',
    setUp: () => when(() => usecase.getAttachments(7))
        .thenAnswer((_) async => const Right(GetAttachmentsResModel(status: true, data: [_photo, _pdf]))),
    build: () => AttachmentCubit(7),
    act: (c) => c.load(),
    expect: () => [
      isA<AttachmentState>().having((s) => s.loading, 'loading', true),
      isA<AttachmentState>().having((s) => s.attachments, 'attachments', [_photo, _pdf]),
    ],
  );

  blocTest<AttachmentCubit, AttachmentState>(
    'upload reports progress, then adds the new files and clears progress',
    setUp: () {
      when(() => usecase.uploadAttachments(7, any(), onProgress: any(named: 'onProgress'))).thenAnswer((inv) async {
        final onProgress = inv.namedArguments[#onProgress] as void Function(double);
        onProgress(0.5);
        onProgress(0.501); // same whole percent: not emitted again
        onProgress(1);
        return const Right(GetAttachmentsResModel(status: true, message: 'Uploaded', data: [_pdf]));
      });
    },
    build: () => AttachmentCubit(7),
    act: (c) => c.upload([_file]),
    expect: () => [
      isA<AttachmentState>().having((s) => s.busyId, 'busy', -1).having((s) => s.progress, 'progress', 0),
      isA<AttachmentState>().having((s) => s.progress, 'progress', 0.5),
      isA<AttachmentState>().having((s) => s.progress, 'progress', 1),
      isA<AttachmentState>()
          .having((s) => s.attachments, 'attachments', [_pdf])
          .having((s) => s.progress, 'progress', null)
          .having((s) => s.busyId, 'busy', null)
          .having((s) => s.changed, 'changed', true),
      isA<AttachmentState>().having((s) => s.message, 'message', 'Uploaded').having((s) => s.isError, 'error', false),
    ],
  );

  blocTest<AttachmentCubit, AttachmentState>(
    'a failed upload shows the error and clears progress',
    setUp: () => when(() => usecase.uploadAttachments(7, any(), onProgress: any(named: 'onProgress')))
        .thenAnswer((_) async => const Left(BaseResponseModel(status: false, message: 'Access denied'))),
    build: () => AttachmentCubit(7),
    act: (c) => c.upload([_file]),
    skip: 1,
    expect: () => [
      isA<AttachmentState>().having((s) => s.busyId, 'busy', null).having((s) => s.progress, 'progress', null),
      isA<AttachmentState>().having((s) => s.message, 'message', 'Access denied').having((s) => s.isError, 'error', true),
    ],
  );

  blocTest<AttachmentCubit, AttachmentState>(
    'delete removes the attachment',
    setUp: () => when(() => usecase.deleteAttachment(1))
        .thenAnswer((_) async => const Right(BaseResponseModel(status: true, message: 'Deleted'))),
    build: () => AttachmentCubit(7),
    seed: () => const AttachmentState(attachments: [_photo, _pdf]),
    act: (c) => c.delete(_photo),
    skip: 1,
    expect: () => [
      isA<AttachmentState>().having((s) => s.attachments, 'attachments', [_pdf]),
      isA<AttachmentState>().having((s) => s.message, 'message', 'Deleted'),
    ],
  );

  test('thumbnail, preview and download share one request', () async {
    final bytes = Uint8List.fromList([9, 9, 9]);
    when(() => usecase.downloadAttachment(1)).thenAnswer((_) async => Right(bytes));
    final cubit = AttachmentCubit(7);

    expect(await cubit.thumbnailBytes(_photo), bytes);
    expect(await cubit.thumbnailBytes(_photo), bytes);
    expect(await cubit.download(_photo), bytes);

    verify(() => usecase.downloadAttachment(1)).called(1);
    await cubit.close();
  });

  test('a failed thumbnail is retried next time', () async {
    var calls = 0;
    when(() => usecase.downloadAttachment(1)).thenAnswer((_) async {
      calls++;
      return calls == 1
          ? const Left(BaseResponseModel(status: false, message: 'offline'))
          : Right(Uint8List.fromList([1]));
    });
    final cubit = AttachmentCubit(7);

    expect(await cubit.thumbnailBytes(_photo), isNull);
    expect(await cubit.thumbnailBytes(_photo), isNotNull);
    expect(calls, 2);
    await cubit.close();
  });
}
