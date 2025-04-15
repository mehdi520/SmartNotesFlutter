import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/user/req_model/pass_change_req_model.dart';
import 'package:note_book/domain/models/user/req_model/update_profile_req_model.dart';
import 'package:note_book/domain/user/usecases/update_profile_usecase.dart';
import 'package:note_book/domain/user/usecases/get_profile_usecase.dart';
import 'package:note_book/domain/models/user/data_model/user_model.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/di/service_locator.dart';
import 'package:note_book/domain/user/usecases/change_password_usecase.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UpdateProfileUsecase updateProfileUsecase = sl<UpdateProfileUsecase>();
  final GetProfileUsecase getProfileUsecase = sl<GetProfileUsecase>();
  final ChangePasswordUsecase changePasswordUsecase = sl<ChangePasswordUsecase>();

  UserBloc() : super(const UserState()) {
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<GetProfileEvent>(_onGetProfile);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  void _onUpdateProfile(UpdateProfileEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading));
    try {
      Either returnedData = await updateProfileUsecase.call(params: event.req);
      returnedData.fold(
        (error) {
          print(error);
          emit(
            state.copyWith(
              apiStatus: ApiStatus.error,
              resp: error,
            ),
          );
        },
        (data) {
          // Update local user data
          final user = HiveManager.getUserJson();
          if (user != null) {
            user.name = event.req.name;
            user.phone = event.req.phone;
            HiveManager.saveUserJson(user);
            emit(state.copyWith(
              apiStatus: ApiStatus.success,
              resp: data,
              user: user,
            ));
          } else {
            emit(state.copyWith(
              apiStatus: ApiStatus.success,
              resp: data,
            ));
          }
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          apiStatus: ApiStatus.error,
          resp: BaseResponseModel(status: false, message: e.toString()),
        ),
      );
    }
  }

  void _onGetProfile(GetProfileEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading));
    try {
      Either returnedData = await getProfileUsecase.call();
      returnedData.fold(
        (error) {
          print(error);
          emit(
            state.copyWith(
              apiStatus: ApiStatus.error,
              resp: error,
            ),
          );
        },
        (data) {
          final user = HiveManager.getUserJson();
          emit(state.copyWith(
            apiStatus: ApiStatus.success,
            resp: data,
            user: user,
          ));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          apiStatus: ApiStatus.error,
          resp: BaseResponseModel(status: false, message: e.toString()),
        ),
      );
    }
  }

  Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading));
    final result = await changePasswordUsecase(event.req);
    result.fold(
      (failure) => emit(state.copyWith(
        apiStatus: ApiStatus.error,
        resp: BaseResponseModel(status: false, message: failure.message),
      )),
      (success) => emit(state.copyWith(
        apiStatus: ApiStatus.success,
        resp: success,
      )),
    );
  }
} 