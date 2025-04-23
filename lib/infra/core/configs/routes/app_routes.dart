
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/presentation/blocs/cat_bloc/cat_bloc.dart';
import 'package:note_book/presentation/blocs/note_bloc/note_bloc.dart';
import 'package:note_book/presentation/cat/add_update_cat.dart';
import 'package:note_book/presentation/cat/update_note_book_screen.dart';
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
  static const String updateNoteBook = "/UpdateNoteBookScreen";


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
        final noteBookId = settings.arguments as int;
        return MaterialPageRoute(builder: (context) => NoteScreen(noteBookId: noteBookId,));
      case categoryRoute:
        final bloc = settings.arguments as CatBloc;
        return MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: bloc,
              child: AddUpdateCat()
            ));
      case accRoute:
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case addnote:
        final args = settings.arguments as Map<String, dynamic>;
        final noteBloc = args['bloc'] as NoteBloc;
        final noteId = args['noteId'] as int;
        final note = args['note'] as NoteDataModel?;
        return MaterialPageRoute(builder: (context) => BlocProvider.value(value: noteBloc , child: AddUpdateNoteScreen(noteBookId: noteId,note: note,),));

      case updateNoteBook:
        final args = settings.arguments as Map<String, dynamic>;
        final noteBloc = args['bloc'] as CatBloc;
        final cat = args['cat'] as CatModel;
        return MaterialPageRoute(builder: (context) => BlocProvider.value(value: noteBloc , child: UpdateNoteBookScreen( cat:cat ),));

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

