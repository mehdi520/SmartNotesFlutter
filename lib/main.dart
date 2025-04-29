import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/presentation/blocs/user_bloc/user_bloc.dart';
import 'package:note_book/presentation/pub/splash/bloc/splash_cubit.dart';

import 'infra/core/core_exports.dart';
import 'infra/di/service_locator.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializedDepencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
            SplashCubit()
              ..appStarted()
        ),
        BlocProvider(
          create: (context) => UserBloc(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.appTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splashRoute,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
