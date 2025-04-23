import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:note_book/domain/category/usecases/category_use_cases.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/infra/di/service_locator.dart';
import 'package:note_book/infra/utils/enums.dart';

part 'cat_event.dart';
part 'cat_state.dart';

class CatBloc extends Bloc<CatEvent, CatState> {
  final CategoryUseCases categoryUseCases = sl<CategoryUseCases>();

  CatBloc() : super(CatState()) {
    on<GetCatEvent>(_onGetCats);
    on<AddupdateCatEvent>(_onAddUpdateCat);
    on<UpdateIconColorEvent>(_onUpdateIconColor);
    on<DeleteCatEvent>(_onDeleteNoteBook);
  }

  void _onGetCats (GetCatEvent event, Emitter<CatState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading,apiIdentifier: "get_cat"));
    try {
      Either returnedData = await categoryUseCases.getCats();
      returnedData.fold(
            (error) {
          print(error);
          emit(
            state.copyWith(
              apiStatus: ApiStatus.error,
              resp: error,
                apiIdentifier: "get_cat"
            ),
          );
        },
            (data) {
          // Update local user data
          emit(state.copyWith(
            apiStatus: ApiStatus.success,
            resp: BaseResponseModel(status: true, message: ""),
            cats: data.data,
              apiIdentifier: "get_cat"
          ));
          // Reset to initial after success
          emit(state.copyWith(apiStatus: ApiStatus.initial,apiIdentifier: "get_cat"));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          apiStatus: ApiStatus.error,
          resp: BaseResponseModel(status: false, message: e.toString()),
            apiIdentifier: "get_cat"
        ),
      );
    }
  }

  void _onAddUpdateCat(AddupdateCatEvent event, Emitter<CatState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading,  apiIdentifier : "add_update"));
    try {
      Either returnedData = await categoryUseCases.addOrUpdateCat(event.req);
      returnedData.fold(
            (error) {
          print(error);
          emit(
            state.copyWith(
              apiStatus: ApiStatus.error,
              resp: error,
                apiIdentifier : "add_update"
            ),
          );
        },
            (data) {
          // Update local user data
          emit(state.copyWith(
            apiStatus: ApiStatus.success,
            resp: data,
              apiIdentifier : "add_update"
          ));
          // Reset to initial after success
          emit(state.copyWith(apiStatus: ApiStatus.initial,  apiIdentifier : "add_update"));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          apiStatus: ApiStatus.error,
          resp: BaseResponseModel(status: false, message: e.toString()),
            apiIdentifier : "add_update"
        ),
      );
    }
  }

  void _onUpdateIconColor(UpdateIconColorEvent event, Emitter<CatState> emit)
  {
    print("selectedColor" + event.iconColor);
    emit(state.copyWith(selectedIconColor: event.iconColor,apiIdentifier: "add_update"));
  }

  void _onDeleteNoteBook(DeleteCatEvent event, Emitter<CatState> emit) async
  {
    emit(state.copyWith(apiStatus: ApiStatus.loading,  apiIdentifier : "delete"));
    try {
      Either returnedData = await categoryUseCases.deleteCat(event.noteBookId);
      returnedData.fold(
            (error) {
          print(error);
          emit(
            state.copyWith(
                apiStatus: ApiStatus.error,
                resp: error,
                apiIdentifier : "add_update"
            ),
          );
        },
            (data) {
          // Update local user data
          emit(state.copyWith(
              apiStatus: ApiStatus.success,
              resp: data,
              apiIdentifier : "delete"
          ));
          // Reset to initial after success
          emit(state.copyWith(apiStatus: ApiStatus.initial,  apiIdentifier : "delete"));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
            apiStatus: ApiStatus.error,
            resp: BaseResponseModel(status: false, message: e.toString()),
            apiIdentifier : "delete"
        ),
      );
    }
  }

}
