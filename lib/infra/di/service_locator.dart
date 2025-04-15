
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';

import '../../data/data_sources/remote/api_service.dart';
import '../../data/repository/auth/auth_repository_impl.dart';
import '../../domain/auth/contract/auth_repository.dart';
import '../../domain/auth/usecases/signup_usecase.dart';
import '../core/configs/constants/constants.dart';


final sl = GetIt.instance;

Future<void> initializedDepencies() async {
// Initialize Hive and register adapters
  await HiveManager.init();
  // // Register HiveManager
  // sl.registerLazySingleton<HiveManager>(() => HiveManager());


  final dio = Dio();
  if(kIsWeb)
  {
    dio.options = BaseOptions(
      baseUrl: APIBaseURL,
      connectTimeout: Duration(minutes: 2),
      receiveTimeout: Duration(minutes: 2),
    );

  }
  else {
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


  // dio.interceptors.add(AuthInterceptor(getToken));
  // dio.interceptors.add(LoggingInterceptor());

  sl.registerSingleton<Dio>(dio);

  // Remote Api Services
  sl.registerSingleton(ApiService(sl()));


  // repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  // sl.registerSingleton<CategoryRepository>(CategoryRepositoryImpl(sl(), sl()));
  // sl.registerSingleton<IncomeRepository>(IncomeRespositoryImpl(sl(), sl()));
  // sl.registerSingleton<ExpenseRepository>(ExpenseRepositoryImpl(sl(), sl()));
  // sl.registerSingleton<UserRepository>(UserRepositoryImpl(sl(), sl()));
  // sl.registerSingleton<LocalStorageRepository>(LocalStorageRepositoryImpl(sl()));

  // usecases
  sl.registerSingleton<SignupUsecase>(SignupUsecase());
 // sl.registerSingleton<GetCategoryUsecase>(GetCategoryUsecase());

}