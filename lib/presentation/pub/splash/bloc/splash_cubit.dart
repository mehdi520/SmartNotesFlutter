import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';

import '../../../../infra/di/service_locator.dart';
part 'splash_state.dart';


class SplashCubit extends Cubit<SplashState> {
 // final SecureStorage _secureStorage;


  // SplashCubit(this._secureStorage) : super(DisplaySplash());

  SplashCubit() : super(DisplaySplash());

  void appStarted() async{
     await Future.delayed(const Duration(seconds: 2));
    String? token =  HiveManager.getToken();
   if(token == null || token.isEmpty) {
      emit(UnAuthenticated());
    }
    else
    {
      print("token is ) " + token);

      emit(Authenticated());
    }
  }
}
