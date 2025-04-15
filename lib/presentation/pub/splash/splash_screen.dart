import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../infra/core/configs/assets/app_images.dart';
import '../../../infra/core/core_exports.dart';
import 'bloc/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
      if (state is UnAuthenticated) {

        Navigator.pushReplacementNamed(
            context,  AppRoutes.loginRoute
        );
      }
      else if(state is Authenticated)
      {
        Navigator.pushReplacementNamed(
          context,  AppRoutes.landingRoute,
          // arguments: sl<SecureStorage>(),
        );
      }
    },
    child: Scaffold(
            body: Stack(children: [
              // Container(child: Image.asset(AppImages.app_bg)),
              Center(
                child:
                Container(width: 150, child: Image.asset(AppImages.logo)),
              ),
            ])
    )
    );
  }
}
