import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/domain/models/user/req_model/update_profile_req_model.dart';
import 'package:note_book/infra/common/common_widgets/buttons/PrimaryButton.dart';
import 'package:note_book/infra/common/common_widgets/input_fields/TextInputFormField.dart';
import 'package:note_book/infra/core/core_exports.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/infra/utils/validation_utils.dart';
import 'package:note_book/presentation/blocs/user_bloc/user_bloc.dart';

class ProfileScreen extends StatelessWidget {
   ProfileScreen({super.key});
  final OverlayService _loadingService = OverlayService();

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
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

  @override
  Widget build(BuildContext context) {
    final user = HiveManager.getUserJson();
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user data found'),
        ),
      );
    }

    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: user.name);
    final _emailController = TextEditingController(text: user.email);
    final _phoneController = TextEditingController(text: user.phone);
    final _dateController = TextEditingController(text: user.createdAt);

    void _updateProfile() {
      if (_formKey.currentState!.validate()) {
        context.read<UserBloc>().add(
          UpdateProfileEvent(
            req: UpdateProfileReqModel(
              name: _nameController.text,
              phone: _phoneController.text,
              email: _emailController.text
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
          ToastUtils.showSuccess(state.resp?.message ?? 'Profile updated successfully');
        } else if (state.apiStatus == ApiStatus.error) {
          _loadingService.hideLoadingOverlay();
          ToastUtils.showError(state.resp?.message ?? 'Failed to update profile');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: AppColors.primary,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user.name.toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Textinputformfield(
                    hintText: 'Enter your name',
                    ctrl: _nameController,
                    formLabel: 'Name',
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  Textinputformfield(
                    hintText: 'Enter your email',
                    ctrl: _emailController,
                    formLabel: 'Email',
                    isEnabled: false,
                  ),
                  const SizedBox(height: 16),
                  Textinputformfield(
                    hintText: 'Enter your phone number',
                    ctrl: _phoneController,
                    formLabel: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 16),
                  Textinputformfield(
                    hintText: 'Date of Join',
                    ctrl: _dateController,
                    formLabel: 'Date of Join',
                    isEnabled: false,
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    text: 'Update Profile',
                    onTap: _updateProfile,
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
