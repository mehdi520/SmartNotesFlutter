import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_notes_res_model.dart';
import 'package:note_book/domain/note/usecase/note_usecase.dart';
import 'package:note_book/infra/di/service_locator.dart';
import 'package:note_book/infra/utils/enums.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteUsecase noteUsecase = sl<NoteUsecase>();

  NoteBloc() : super(NoteState()) {
    on<AddUpdateNoteEvent>(_onAddUpdateNote);
    on<GetNotesEvent>(_onGetNotes);
    on<DelNoteEvent>(_onDelNote);
  }

  void _onAddUpdateNote (AddUpdateNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading,  apiIdentifier : "add_update_note"));
    try {
      Either returnedData = await noteUsecase.addOrUpdateNote(event.req);
      returnedData.fold(
            (error) {
          print(error);
          emit(
            state.copyWith(
                apiStatus: ApiStatus.error,
                resp: error,
                apiIdentifier : "add_update_note"
            ),
          );
        },
            (data) {
          // Update local user data
          emit(state.copyWith(
              apiStatus: ApiStatus.success,
              resp: data,
              apiIdentifier : "add_update_note"
          ));
          // Reset to initial after success
          emit(state.copyWith(apiStatus: ApiStatus.initial,  apiIdentifier : "add_update_note"));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
            apiStatus: ApiStatus.error,
            resp: BaseResponseModel(status: false, message: e.toString()),
            apiIdentifier : "add_update_note"
        ),
      );
    }
  }

  void _onGetNotes (GetNotesEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading,apiIdentifier: "get_notes"));
    try {
      Either returnedData = await noteUsecase.getNotes(event.req);
      returnedData.fold(
            (error) {
          print(error);
          emit(
            state.copyWith(
                apiStatus: ApiStatus.error,
                resp: error,
                apiIdentifier: "get_notes"
            ),
          );
        },
            (data) {
              final GetNotesResModel model = data;
              final currentPage = (state.notes.length / 10).ceil();

              List<NoteDataModel> updatedNotes = [];
              if(currentPage == 1)
                {
                  updatedNotes = model.data ?? [];
                }
              else
                {
                  updatedNotes = [...state.notes, ...model.data ?? []];
                }

              emit(state.copyWith(
                apiStatus: ApiStatus.success,
                resp: BaseResponseModel(status: true, message: ""),
                notes: updatedNotes,
                totalPage: model.totalPage,
                hasReachedMax: event.req.pageNo >= model.totalPage,
                apiIdentifier: "get_notes",
              ));

              emit(state.copyWith(apiStatus: ApiStatus.initial, apiIdentifier: "get_notes"));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
            apiStatus: ApiStatus.error,
            resp: BaseResponseModel(status: false, message: e.toString()),
            apiIdentifier: "get_notes"
        ),
      );
    }
  }

  void _onDelNote (DelNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading,  apiIdentifier : "add_update_note"));
    try {
      Either returnedData = await noteUsecase.deleteNote(event.noteId);
      returnedData.fold(
            (error) {
          print(error);
          emit(
            state.copyWith(
                apiStatus: ApiStatus.error,
                resp: error,
                apiIdentifier : "add_update_note"
            ),
          );
        },
            (data) {
          // Update local user data
          emit(state.copyWith(
              apiStatus: ApiStatus.success,
              resp: data,
              apiIdentifier : "add_update_note"
          ));
          // Reset to initial after success
          emit(state.copyWith(apiStatus: ApiStatus.initial,  apiIdentifier : "add_update_note"));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
            apiStatus: ApiStatus.error,
            resp: BaseResponseModel(status: false, message: e.toString()),
            apiIdentifier : "add_update_note"
        ),
      );
    }
  }

}
