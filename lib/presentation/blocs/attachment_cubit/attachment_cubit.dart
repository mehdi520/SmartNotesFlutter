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
import 'package:note_book/infra/files/video_thumbnail_helper.dart';

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

  /// 0.0–1.0 while an upload / replace is being sent, otherwise null.
  final double? progress;

  const AttachmentState({
    this.attachments = const [],
    this.loading = false,
    this.busyId,
    this.message,
    this.isError = false,
    this.messageId = 0,
    this.changed = false,
    this.progress,
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
    double? Function()? progress,
  }) =>
      AttachmentState(
        attachments: attachments ?? this.attachments,
        loading: loading ?? this.loading,
        busyId: busyId != null ? busyId() : this.busyId,
        message: message ?? this.message,
        isError: isError ?? this.isError,
        messageId: messageId ?? this.messageId,
        changed: changed ?? this.changed,
        progress: progress != null ? progress() : this.progress,
      );

  @override
  List<Object?> get props => [attachments, loading, busyId, message, isError, messageId, changed, progress];
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

  String? _msg(dynamic error) => error is BaseResponseModel ? error.message : null;

  /// Progress callback that emits at most once per whole percent.
  void Function(double) _onProgress() {
    var last = -1;
    return (p) {
      final pct = (p * 100).floor();
      if (pct == last || isClosed) return;
      last = pct;
      emit(state.copyWith(progress: () => p));
    };
  }

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
    emit(state.copyWith(busyId: () => -1, progress: () => 0));
    final Either r = await _usecase.uploadAttachments(noteId, files, onProgress: _onProgress());
    r.fold(
      (e) {
        emit(state.copyWith(busyId: () => null, progress: () => null));
        _toast(_msg(e), error: true);
      },
      (data) {
        final res = data as GetAttachmentsResModel;
        emit(state.copyWith(
          busyId: () => null,
          progress: () => null,
          attachments: [...state.attachments, ...res.data],
          changed: true,
        ));
        _toast(res.message);
      },
    );
  }

  Future<void> replace(NoteAttachmentModel a, PickedFileModel file) async {
    emit(state.copyWith(busyId: () => a.attachmentId, progress: () => 0));
    final Either r = await _usecase.replaceAttachment(a.attachmentId, file, onProgress: _onProgress());
    r.fold(
      (e) {
        emit(state.copyWith(busyId: () => null, progress: () => null));
        _toast(_msg(e), error: true);
      },
      (data) {
        _bytes.remove(a.attachmentId);
        _videoThumbs.remove(a.attachmentId); // file content changed
        _videoThumbs.remove(a.attachmentId);
        final res = data as GetAttachmentsResModel;
        final updated = res.data.isEmpty ? null : res.data.first;
        emit(state.copyWith(
          busyId: () => null,
          progress: () => null,
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
        _bytes.remove(a.attachmentId);
        emit(state.copyWith(
          busyId: () => null,
          changed: true,
          attachments: state.attachments.where((x) => x.attachmentId != a.attachmentId).toList(),
        ));
        _toast((data as BaseResponseModel).message);
      },
    );
  }

  /// Downloaded bytes by attachment id, so a thumbnail, its preview and a save share one download.
  final Map<int, Future<Uint8List?>> _bytes = {};

  /// Bytes for a thumbnail: cached, and silent on failure (the tile just shows an icon).
  Future<Uint8List?> thumbnailBytes(NoteAttachmentModel a) {
    return _bytes[a.attachmentId] ??= _usecase.downloadAttachment(a.attachmentId).then((Either r) {
      final bytes = r.fold((_) => null, (b) => b as Uint8List);
      if (bytes == null) _bytes.remove(a.attachmentId); // allow a retry later
      return bytes;
    });
  }

  /// Video preview frames by attachment id. The video itself is not kept in memory.
  final Map<int, Future<Uint8List?>> _videoThumbs = {};

  /// Videos bigger than this are not downloaded just to draw a tile.
  static const int maxVideoThumbnailBytes = 15 * 1024 * 1024;

  /// A preview frame for a video attachment, or null (unsupported platform, too big, failed).
  Future<Uint8List?>? videoThumbnail(NoteAttachmentModel a) {
    if (!VideoThumbnailHelper.isSupported || !isVideoFileName(a.fileName)) return null;
    if (a.fileSize > maxVideoThumbnailBytes) return null;
    return _videoThumbs[a.attachmentId] ??= () async {
      final Either r = await _usecase.downloadAttachment(a.attachmentId);
      final video = r.fold((_) => null, (b) => b as Uint8List);
      if (video == null) {
        _videoThumbs.remove(a.attachmentId);
        return null;
      }
      return VideoThumbnailHelper.fromBytes(video, a.fileName);
    }();
  }

  /// Bytes for preview / save. Returns null (and shows a toast) on failure.
  Future<Uint8List?> download(NoteAttachmentModel a) async {
    final cached = await _bytes[a.attachmentId];
    if (cached != null) return cached;
    final Either r = await _usecase.downloadAttachment(a.attachmentId);
    return r.fold(
      (e) {
        _toast(_msg(e), error: true);
        return null;
      },
      (bytes) {
        _bytes[a.attachmentId] = Future.value(bytes as Uint8List);
        return bytes;
      },
    );
  }
}
