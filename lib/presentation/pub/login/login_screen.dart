import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/auth_models/login_req_model.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
import 'package:note_book/infra/common/common_widgets/form_fields/PrimaryTextInputField.dart';
import 'package:note_book/infra/core/configs/theme/app_colors.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/validation_utils.dart';
import 'package:note_book/presentation/blocs/auth_bloc/auth_bloc.dart';

import '../../../infra/common/common_widgets/buttons/PrimaryButton.dart';
import '../../../infra/common/common_widgets/input_fields/TextInputFormField.dart';
import '../../../infra/common/common_widgets/text_fields/CommonTextField.dart';
import '../../../infra/core/core_exports.dart';
import '../../../infra/utils/toast_utils.dart';

class LoginScreen extends StatelessWidget {
  final OverlayService _loadingService = OverlayService();

  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!ValidationUtils.isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 2) {
      return 'Password must be at least 3 characters long';
    }
    return null;
  }

  void _submitLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          req: SignUpReqModel(
            email: _emailController.text.trim(),
            password: _passController.text, name: 'dfger',phone: '3535'
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(),
      child: Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.apiStatus == ApiStatus.loading) {
              _loadingService.showLoadingOverlay(context);
            }
            if (state.apiStatus == ApiStatus.success) {
              _loadingService.hideLoadingOverlay();
              Navigator.pushReplacementNamed(context, AppRoutes.landingRoute);
            }
            if (state.apiStatus == ApiStatus.error) {
              _loadingService.hideLoadingOverlay();
              ToastUtils.showError(state.resp?.message ?? 'Login failed');
            }
          },
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.mediaQueryHeight * 0.1),
                        Center(
                          child: SizedBox(
                            width: 110,
                            child: Image.asset(
                              AppImages.logo,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        CommontextField(
                          contentText: 'Welcome back!',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        const SizedBox(height: 2),
                        CommontextField(
                          contentText: 'Enter your credentials below to get started.',
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                        const SizedBox(height: 30),
                        Textinputformfield(
                          hintText: 'Enter your email here',
                          ctrl: _emailController,
                          formLabel: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 10),
                        Textinputformfield(
                          hintText: 'Enter your password here',
                          ctrl: _passController,
                          formLabel: 'Password',
                          isSecureTextField: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 30),
                        Builder(
                          builder: (context) {
                            return PrimaryButton(
                              text: 'Login',
                              onTap: () => _submitLogin(context),
                            );
                          }
                        ),
                        const SizedBox(height: 20),
                        _dont_have_Acc(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dont_have_Acc(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.registerRoute);
          },
          child: Text(
            'Do not have an Account?',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Center(
          child: Container(
            height: 2,
            width: 190,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
