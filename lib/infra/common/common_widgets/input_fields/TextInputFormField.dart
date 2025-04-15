import 'package:flutter/material.dart';

import '../form_fields/PrimaryTextInputField.dart';

class Textinputformfield extends StatelessWidget {
  final TextEditingController ctrl;
  final TextInputAction? imeAction;
  final TextInputType? keyboardType;
  final bool? isSecureTextField;
  final String? Function(String?)? validator;
  final String hintText;
  final String formLabel;

  const Textinputformfield({
    super.key,
    required this.hintText,
    this.imeAction,
    this.keyboardType,
    this.isSecureTextField,
    this.validator,
    required this.ctrl,
    required this.formLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(formLabel,style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16
            ),),
          ),
          SizedBox(height: 8),
          Primarytextinputfield(
            hintText: hintText,
            ctrl: ctrl,
            imeAction: imeAction,keyboardType: keyboardType,
            isSecureTextField: isSecureTextField,
            validator: validator,
          )

        ],
      ),
    );
  }
}
