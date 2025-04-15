import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:note_book/domain/auth/usecases/login_usecase.dart';
import 'package:note_book/domain/auth/usecases/signup_usecase.dart';
import 'package:note_book/domain/models/auth_models/response_model/login/login_res_model.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/di/service_locator.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUsecase signupUsecase = sl<SignupUsecase>();
  final LoginUsecase loginUsecase = sl<LoginUsecase>();

  AuthBloc() : super(const AuthState()) {
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignUp);
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading));
    try {
      Either returnedData = await loginUsecase(event.req);
      returnedData.fold(
        (error) {
          print(error);
          emit(
            state.copyWith(
              apiStatus: ApiStatus.error,
              resp: LoginResModel(status: false, message: error.message),
            ),
          );
        },
        (data) {
          emit(state.copyWith(apiStatus: ApiStatus.success, resp: data));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          apiStatus: ApiStatus.error,
          resp: LoginResModel(status: false, message: e.toString()),
        ),
      );
    }
  }

  void _onSignUp(SignupEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading));
    try {
      Either returnedData = await signupUsecase.call(params: event.req);
      returnedData.fold(
        (error) {
          print(error);
          emit(
            state.copyWith(
              apiStatus: ApiStatus.error,
              resp: LoginResModel(status: false, message: error.message),
            ),
          );
        },
        (data) {
          emit(state.copyWith(apiStatus: ApiStatus.success, resp: data));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          apiStatus: ApiStatus.error,
          resp: LoginResModel(status: false, message: e.toString()),
        ),
      );
    }
  }
}
