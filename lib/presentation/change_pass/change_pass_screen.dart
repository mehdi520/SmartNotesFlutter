import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/user/req_model/pass_change_req_model.dart';
import 'package:note_book/infra/common/common_widgets/buttons/PrimaryButton.dart';
import 'package:note_book/infra/common/common_widgets/input_fields/TextInputFormField.dart';
import 'package:note_book/infra/core/core_exports.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/user_bloc/user_bloc.dart';

class ChangePassScreen extends StatelessWidget {
  ChangePassScreen({super.key});
  final OverlayService _loadingService = OverlayService();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    void changePassword() {
      if (formKey.currentState!.validate()) {
        context.read<UserBloc>().add(
          ChangePasswordEvent(
            req: PassChangeReqModel(
              oldPass: currentPasswordController.text,
              newPass: newPasswordController.text,
            ),
          ),
        );
      }
    }

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state.apiStatus == ApiStatus.loading) {
          _loadingService.showLoadingOverlay(context);
        } else if (state.apiStatus == ApiStatus.success) {
          _loadingService.hideLoadingOverlay();
          ToastUtils.showSuccess(state.resp?.message ?? 'Password changed successfully');
          Navigator.pop(context);
        } else if (state.apiStatus == ApiStatus.error) {
          _loadingService.hideLoadingOverlay();
          ToastUtils.showError(state.resp?.message ?? 'Failed to change password');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Change Password'),
          backgroundColor: AppColors.primary,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Textinputformfield(
                    hintText: 'Enter current password',
                    ctrl: currentPasswordController,
                    formLabel: 'Current Password',
                    isSecureTextField: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  Textinputformfield(
                    hintText: 'Enter new password',
                    ctrl: newPasswordController,
                    formLabel: 'New Password',
                    isSecureTextField: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  Textinputformfield(
                    hintText: 'Confirm new password',
                    ctrl: confirmPasswordController,
                    formLabel: 'Confirm Password',
                    isSecureTextField: true,
                    validator: (value) => _validateConfirmPassword(
                      value,
                      newPasswordController.text,
                    ),
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    text: 'Change Password',
                    onTap: changePassword,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 