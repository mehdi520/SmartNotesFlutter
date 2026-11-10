import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_attachment_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_attachments_res_model.dart';
import 'package:note_book/domain/note/usecase/note_usecase.dart';
import 'package:note_book/infra/di/service_locator.dart';

class AttachmentState extends Equatable {
  final List<NoteAttachmentModel> attachments;
  final bool loading;
  /// Id of the attachment currently being changed (-1 = upload, null = none).
  final int? busyId;
  /// One-shot message for a toast; [messageId] changes every time so the listener fires.
  final String? message;
  final bool isError;
  final int messageId;
  /// True if anything changed on the server (so the notes list can refresh counts).
  final bool changed;

  const AttachmentState({
    this.attachments = const [],
    this.loading = false,
    this.busyId,
    this.message,
    this.isError = false,
    this.messageId = 0,
    this.changed = false,
  });

  bool get isBusy => loading || busyId != null;

  AttachmentState copyWith({
    List<NoteAttachmentModel>? attachments,
    bool? loading,
    int? Function()? busyId,
    String? message,
    bool? isError,
    int? messageId,
    bool? changed,
  }) =>
      AttachmentState(
        attachments: attachments ?? this.attachments,
        loading: loading ?? this.loading,
        busyId: busyId != null ? busyId() : this.busyId,
        message: message ?? this.message,
        isError: isError ?? this.isError,
        messageId: messageId ?? this.messageId,
        changed: changed ?? this.changed,
      );

  @override
  List<Object?> get props => [attachments, loading, busyId, message, isError, messageId, changed];
}

/// Attachments of one saved note (create / replace / rename / delete / download).
class AttachmentCubit extends Cubit<AttachmentState> {
  final NoteUsecase _usecase = sl<NoteUsecase>();
  final int noteId;

  AttachmentCubit(this.noteId) : super(const AttachmentState());

  void _toast(String? msg, {bool error = false}) => emit(state.copyWith(
        message: msg ?? (error ? 'Something went wrong' : ''),
        isError: error,
        messageId: state.messageId + 1,
      ));

  String? _msg(dynamic error) => error is BaseResponseModel ? error.message : error?.toString();

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final Either r = await _usecase.getAttachments(noteId);
    r.fold(
      (e) {
        emit(state.copyWith(loading: false));
        _toast(_msg(e), error: true);
      },
      (data) => emit(state.copyWith(loading: false, attachments: (data as GetAttachmentsResModel).data)),
    );
  }

  Future<void> upload(List<PickedFileModel> files) async {
    if (files.isEmpty) return;
    emit(state.copyWith(busyId: () => -1));
    final Either r = await _usecase.uploadAttachments(noteId, files);
    r.fold(
      (e) {
        emit(state.copyWith(busyId: () => null));
        _toast(_msg(e), error: true);
      },
      (data) {
        final res = data as GetAttachmentsResModel;
        emit(state.copyWith(
          busyId: () => null,
          attachments: [...state.attachments, ...res.data],
          changed: true,
        ));
        _toast(res.message);
      },
    );
  }

  Future<void> replace(NoteAttachmentModel a, PickedFileModel file) async {
    emit(state.copyWith(busyId: () => a.attachmentId));
    final Either r = await _usecase.replaceAttachment(a.attachmentId, file);
    r.fold(
      (e) {
        emit(state.copyWith(busyId: () => null));
        _toast(_msg(e), error: true);
      },
      (data) {
        final res = data as GetAttachmentsResModel;
        final updated = res.data.isEmpty ? null : res.data.first;
        emit(state.copyWith(
          busyId: () => null,
          changed: true,
          attachments: state.attachments
              .map((x) => x.attachmentId == a.attachmentId && updated != null ? updated : x)
              .toList(),
        ));
        _toast(res.message);
      },
    );
  }

  Future<void> rename(NoteAttachmentModel a, String newName) async {
    if (newName.trim().isEmpty || newName.trim() == a.fileName) return;
    emit(state.copyWith(busyId: () => a.attachmentId));
    final Either r = await _usecase.renameAttachment(a.attachmentId, newName.trim());
    await r.fold(
      (e) async {
        emit(state.copyWith(busyId: () => null));
        _toast(_msg(e), error: true);
      },
      (data) async {
        emit(state.copyWith(busyId: () => null, changed: true));
        await load(); // server may have adjusted the name (extension / duplicates)
        _toast((data as BaseResponseModel).message);
      },
    );
  }

  Future<void> delete(NoteAttachmentModel a) async {
    emit(state.copyWith(busyId: () => a.attachmentId));
    final Either r = await _usecase.deleteAttachment(a.attachmentId);
    r.fold(
      (e) {
        emit(state.copyWith(busyId: () => null));
        _toast(_msg(e), error: true);
      },
      (data) {
        emit(state.copyWith(
          busyId: () => null,
          changed: true,
          attachments: state.attachments.where((x) => x.attachmentId != a.attachmentId).toList(),
        ));
        _toast((data as BaseResponseModel).message);
      },
    );
  }

  /// Bytes for preview / save. Returns null (and shows a toast) on failure.
  Future<Uint8List?> download(NoteAttachmentModel a) async {
    final Either r = await _usecase.downloadAttachment(a.attachmentId);
    return r.fold(
      (e) {
        _toast(_msg(e), error: true);
        return null;
      },
      (bytes) => bytes as Uint8List,
    );
  }
}
