import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/common_models/page_info.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/data_model/picked_file_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_notes_res_model.dart';
import 'package:note_book/domain/note/usecase/note_usecase.dart';
import 'package:note_book/infra/di/service_locator.dart';
import 'package:note_book/infra/utils/enums.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteUsecase noteUsecase = sl<NoteUsecase>();

  /// Increases with every list request so a slow, older response (e.g. while typing a search)
  /// can't overwrite a newer one.
  int _requestId = 0;

  NoteBloc({int categoryId = 0, int pageSize = 10})
      : super(NoteState(categoryId: categoryId, pageSize: pageSize)) {
    on<AddUpdateNoteEvent>(_onAddUpdateNote);
    on<GetNotesEvent>(_onGetNotes);
    on<SearchNotesEvent>((e, emit) => _load(emit, page: 1, search: e.search));
    on<ChangeNotesPageEvent>((e, emit) => _load(emit, page: e.page));
    on<RefreshNotesEvent>((e, emit) => _load(emit, page: state.pageInfo.currentPage));
    on<DelNoteEvent>(_onDelNote);
  }

  Future<void> _onGetNotes(GetNotesEvent event, Emitter<NoteState> emit) => _load(
        emit,
        page: event.req.pageNo,
        categoryId: event.req.categoryId ?? 0,
        search: event.req.search ?? state.search,
        pageSize: event.req.pageSize,
      );

  Future<void> _load(
    Emitter<NoteState> emit, {
    required int page,
    int? categoryId,
    String? search,
    int? pageSize,
  }) async {
    final requestId = ++_requestId;
    final cat = categoryId ?? state.categoryId;
    final text = search ?? state.search;
    final size = pageSize ?? state.pageSize;

    emit(state.copyWith(
      apiStatus: ApiStatus.loading,
      apiIdentifier: "get_notes",
      categoryId: cat,
      search: text,
      pageSize: size,
    ));

    try {
      final Either returnedData = await noteUsecase.getNotes(PaginationReqModel(
        pageNo: page < 1 ? 1 : page,
        pageSize: size,
        categoryId: cat,
        search: text.isEmpty ? null : text,
      ));
      if (requestId != _requestId) return; // a newer request is running

      returnedData.fold(
        (error) => emit(state.copyWith(apiStatus: ApiStatus.error, resp: error, apiIdentifier: "get_notes")),
        (data) {
          final model = data as GetNotesResModel;
          emit(state.copyWith(
            apiStatus: ApiStatus.success,
            resp: const BaseResponseModel(status: true, message: ""),
            notes: model.data ?? [],
            pageInfo: model.pageInfo,
            loaded: true,
            apiIdentifier: "get_notes",
          ));
          emit(state.copyWith(apiStatus: ApiStatus.initial, apiIdentifier: "get_notes"));
        },
      );
    } catch (e) {
      if (requestId != _requestId) return;
      emit(state.copyWith(
        apiStatus: ApiStatus.error,
        resp: BaseResponseModel(status: false, message: e.toString()),
        apiIdentifier: "get_notes",
      ));
    }
  }

  Future<void> _onAddUpdateNote(AddUpdateNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading, apiIdentifier: "add_update_note"));
    try {
      final Either saved = await noteUsecase.addOrUpdateNote(event.req);
      if (saved.isLeft()) {
        saved.fold((error) => emit(state.copyWith(
            apiStatus: ApiStatus.error, resp: error, apiIdentifier: "add_update_note")), (_) {});
        return;
      }

      BaseResponseModel resp = saved.getOrElse(() => null) as BaseResponseModel;

      // Upload the files picked before saving (new notes have no id until saved).
      final noteId = resp.id ?? event.req.noteId;
      if (event.files.isNotEmpty && noteId > 0) {
        final Either uploaded = await noteUsecase.uploadAttachments(noteId, event.files);
        uploaded.fold(
          (error) => resp = BaseResponseModel(
            status: true,
            id: noteId,
            message: 'Note saved, but attachments failed: ${(error as BaseResponseModel).message ?? ''}',
          ),
          (_) {},
        );
      }

      emit(state.copyWith(apiStatus: ApiStatus.success, resp: resp, apiIdentifier: "add_update_note"));
      emit(state.copyWith(apiStatus: ApiStatus.initial, apiIdentifier: "add_update_note"));
    } catch (e) {
      emit(state.copyWith(
        apiStatus: ApiStatus.error,
        resp: BaseResponseModel(status: false, message: e.toString()),
        apiIdentifier: "add_update_note",
      ));
    }
  }

  Future<void> _onDelNote(DelNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading, apiIdentifier: "delete_note"));
    try {
      final Either returnedData = await noteUsecase.deleteNote(event.noteId);
      returnedData.fold(
        (error) => emit(state.copyWith(apiStatus: ApiStatus.error, resp: error, apiIdentifier: "delete_note")),
        (data) {
          emit(state.copyWith(apiStatus: ApiStatus.success, resp: data, apiIdentifier: "delete_note"));
          emit(state.copyWith(apiStatus: ApiStatus.initial, apiIdentifier: "delete_note"));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        apiStatus: ApiStatus.error,
        resp: BaseResponseModel(status: false, message: e.toString()),
        apiIdentifier: "delete_note",
      ));
    }
  }
}
