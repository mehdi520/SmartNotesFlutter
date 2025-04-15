import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:note_book/infra/utils/validation_utils.dart';

import '../../../infra/common/common_widgets/buttons/PrimaryButton.dart';
import '../../../infra/common/common_widgets/input_fields/TextInputFormField.dart';
import '../../../infra/common/common_widgets/text_fields/CommonTextField.dart';
import '../../../infra/core/core_exports.dart';

class SignupScreen extends StatelessWidget {
  final OverlayService _loadingService = OverlayService();

  SignupScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  TextEditingController _passController = TextEditingController();
  TextEditingController _conFpassController = TextEditingController();

  void _submitLogin(BuildContext context) {

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignupEvent(
          req: SignUpReqModel(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passController.text,
          ),
        ),
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!ValidationUtils.isValidPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

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
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!ValidationUtils.hasUpperCase(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!ValidationUtils.hasLowerCase(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!ValidationUtils.hasNumber(value)) {
      return 'Password must contain at least one number';
    }
    if (!ValidationUtils.hasSpecialChar(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.apiStatus == ApiStatus.loading) {
            _loadingService.showLoadingOverlay(context);
          }
          if (state.apiStatus == ApiStatus.success) {
            print("login success");
            _loadingService.hideLoadingOverlay();
            ToastUtils.showSuccess("Registered successfully");
            Navigator.pop(context);
          }
          if (state.apiStatus == ApiStatus.error) {
            print("login error" + state.resp!.message.toString());
            ToastUtils.showError(state.resp!.message.toString());
            _loadingService.hideLoadingOverlay();
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.mediaQueryHeight * 0.08),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Image.asset(AppImages.back, height: 15),
                            ),
                          ],
                        ),
                        SizedBox(height: context.mediaQueryHeight * 0.05),
                        CommontextField(
                          contentText: 'Register here!',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        SizedBox(height: 2),
                        CommontextField(
                          contentText:
                              'To get started using the app please enter your details below',
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                        SizedBox(height: context.mediaQueryHeight * 0.03),
                        Textinputformfield(
                          hintText: 'Enter your name here',
                          ctrl: _nameController,
                          formLabel: 'Name',
                          validator: _validateName,
                        ),
                        Textinputformfield(
                          hintText: 'Enter your phone here',
                          ctrl: _phoneController,
                          formLabel: 'Phone',
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                        ),
                        SizedBox(height: 10),
                        Textinputformfield(
                          hintText: 'Enter your email here',
                          ctrl: _emailController,
                          formLabel: 'Email',
                          validator: _validateEmail,
                        ),
                        SizedBox(height: 10),
                        Textinputformfield(
                          hintText: 'Enter your password here',
                          ctrl: _passController,
                          formLabel: 'Password',
                          isSecureTextField: true,
                          validator: _validatePassword,
                        ),
                        SizedBox(height: 10),
                        Textinputformfield(
                          hintText: 'Confirm your password here',
                          ctrl: _conFpassController,
                          formLabel: 'Confirm Password',
                          isSecureTextField: true,
                          validator: _validateConfirmPassword,
                        ),
                        SizedBox(height: 30),
                        Builder(
                          builder: (context) {
                            return PrimaryButton(
                              text: 'Register',
                              onTap: () {
                                _submitLogin(context);
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20),
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
            'Already have an Account?',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Center(
          child: Container(height: 2, width: 190, color: AppColors.primary),
        ),
      ],
    );
  }
}
