import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/data/repository/category/category_repository_impl.dart';
import 'package:note_book/data/repository/note/note_repository_impl.dart';
import 'package:note_book/data/repository/user/user_repository_impl.dart';
import 'package:note_book/domain/category/contract/category_repository.dart';
import 'package:note_book/domain/category/usecases/category_use_cases.dart';
import 'package:note_book/domain/note/contract/note_repository.dart';
import 'package:note_book/domain/note/usecase/note_usecase.dart';
import 'package:note_book/domain/user/usecases/change_password_usecase.dart';
import 'package:note_book/infra/network/interceptors/auth_interceptor.dart';
import 'package:note_book/infra/network/interceptors/logging_interceptor.dart';

import '../../data/data_sources/remote/api_service.dart';
import '../../data/repository/auth/auth_repository_impl.dart';
import '../../domain/auth/contract/auth_repository.dart';
import '../../domain/auth/usecases/login_usecase.dart';
import '../../domain/auth/usecases/signup_usecase.dart';
import '../../domain/user/contract/user_repository.dart';
import '../../domain/user/usecases/get_profile_usecase.dart';
import '../../domain/user/usecases/update_profile_usecase.dart';
import '../core/configs/constants/constants.dart';

final sl = GetIt.instance;

Future<void> initializedDepencies() async {
  // Initialize Hive and register adapters
  await HiveManager.init();

  final dio = Dio();
  if(kIsWeb) {
    dio.options = BaseOptions(
      baseUrl: APIBaseURL,
      connectTimeout: Duration(minutes: 2),
      receiveTimeout: Duration(minutes: 2),
    );
  } else {
    final securityContext = SecurityContext(withTrustedRoots: true);
    final httpClient = HttpClient(context: securityContext);

    dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        return httpClient;
      };
  }

  dio.options = BaseOptions(
    baseUrl: APIBaseURL,
    connectTimeout: Duration(minutes: 2),
    receiveTimeout: Duration(minutes: 2),
  );

  dio.interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(),
  ]);

  sl.registerSingleton<Dio>(dio);

  // Remote Api Services
  sl.registerSingleton(ApiService(sl()));

  // repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  sl.registerSingleton<UserRepository>(UserRepositoryImpl(sl()));
  sl.registerSingleton<CategoryRepository>(CategoryRepositoryImpl(sl()));
  sl.registerSingleton<NoteRepository>(NoteRepositoryImpl(sl()));


  // usecases
  sl.registerSingleton<SignupUsecase>(SignupUsecase());
  sl.registerSingleton<LoginUsecase>(LoginUsecase(sl<AuthRepository>()));
  sl.registerSingleton<UpdateProfileUsecase>(UpdateProfileUsecase(sl()));
  sl.registerSingleton<GetProfileUsecase>(GetProfileUsecase(sl()));
  sl.registerSingleton<ChangePasswordUsecase>(ChangePasswordUsecase(sl()));
  sl.registerSingleton<CategoryUseCases>(CategoryUseCases(sl()));
  sl.registerSingleton<NoteUsecase>(NoteUsecase(sl()));

}