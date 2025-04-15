
import 'package:flutter/material.dart';
import 'package:note_book/presentation/cat/add_update_cat.dart';
import 'package:note_book/presentation/change_pass/change_pass_screen.dart';
import 'package:note_book/presentation/home/home_screen.dart';
import 'package:note_book/presentation/notes/add_update_note_screen.dart';
import 'package:note_book/presentation/notes/note_screen.dart';
import 'package:note_book/presentation/profile/profile_screen.dart';
import 'package:note_book/presentation/pub/signup/signup_screen.dart';

import '../../../../presentation/pub/login/login_screen.dart';
import '../../../../presentation/pub/splash/splash_screen.dart';

class AppRoutes{
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotRoute = '/forgot';
  static const String landingRoute = '/landing';
  static const String note = '/note';
  static const String addnote = '/addnote';
  static const String changepass = '/changepass';
  static const String accRoute = '/acc';
  static const String categoryRoute = '/category';


  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case landingRoute:
        return MaterialPageRoute(builder: (context) => NoteDashboardScreen());
      case registerRoute:
        return MaterialPageRoute(builder: (context) => SignupScreen());
      case changepass:
        return MaterialPageRoute(builder: (context) => ChangePassScreen());
      case note:
        return MaterialPageRoute(builder: (context) => NoteScreen());
      case categoryRoute:
        return MaterialPageRoute(builder: (context) => AddUpdateCat());
      case accRoute:
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case addnote:
        return MaterialPageRoute(builder: (context) => AddUpdateNoteScreen());
      case forgotRoute:
       // return MaterialPageRoute(builder: (context) => ForgotPassScreen());
      // case landingRoute:
      //   final secureStorage = settings.arguments as SecureStorage;
      //   return MaterialPageRoute(
      //     builder: (context) => LandingScreen(secureStorage: secureStorage),
      //   );
      //
      // case incomeRoute:
      //   final args = settings.arguments as IncomeRouteArgModel;
      //   return MaterialPageRoute(
      //     builder: (context) => MultiBlocProvider(
      //       providers: [
      //         BlocProvider.value(value: args.userTotalCubit!),
      //         BlocProvider.value(value: args.graphDataCubit!),
      //       ],
      //       child: IncomeScreen(secureStorage: args.secureStorage!),
      //     ),
      //   );
      //
      // case expenseRoute:
      //   final args = settings.arguments as IncomeRouteArgModel;
      //   return MaterialPageRoute(
      //     builder: (context) => MultiBlocProvider(
      //       providers: [
      //         BlocProvider.value(value: args.userTotalCubit!),
      //         BlocProvider.value(value: args.graphDataCubit!),
      //       ],
      //       child: ExpenseScreen(secureStorage: args.secureStorage!),
      //     ),
      //   );
      // case categoryRoute:
      //   final args = settings.arguments as CategoryCubit;
      //   return MaterialPageRoute(
      //     builder: (context) => MultiBlocProvider(
      //       providers: [
      //         BlocProvider.value(value: args),
      //       ],
      //       child: CategoryScreen(),
      //     ),
      //   );
      // case accRoute:
      //   final args = settings.arguments as IncomeRouteArgModel;
      //
      //  // final args = settings.arguments as GetLoggedInCubit;
      //   return MaterialPageRoute(
      //     builder: (context) => MultiBlocProvider(
      //       providers: [
      //         BlocProvider.value(value: args.getLoggedInCubit!),
      //       ],
      //       child: AccScreen(secureStorage: args.secureStorage!,),
      //     ),
      //   );
      default:
        return null;
    }
  }
}

