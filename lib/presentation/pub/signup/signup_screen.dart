import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/auth_bloc/auth_bloc.dart';

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
        LoginEvent(
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
                          children: [Image.asset(AppImages.back, height: 15)],
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        Textinputformfield(
                          hintText: 'Enter your phone here',
                          ctrl: _phoneController,
                          formLabel: 'Phone',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        Textinputformfield(
                          hintText: 'Enter your email here',
                          ctrl: _emailController,
                          formLabel: 'Email',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        Textinputformfield(
                          hintText: 'Enter your password here',
                          ctrl: _passController,
                          formLabel: 'Password',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        Textinputformfield(
                          hintText: 'Confirm your password here',
                          ctrl: _conFpassController,
                          formLabel: 'Confirm Password',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm password is required';
                            }
                            return null;
                          },
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
