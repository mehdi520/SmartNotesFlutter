import 'dart:ffi';

import 'package:flutter/material.dart';

import '../../../core/core_exports.dart';

class Primarytextinputfield extends StatelessWidget {
  final TextEditingController ctrl;
  final TextInputAction? imeAction;
  final TextInputType? keyboardType;
  final bool? isSecureTextField;
  final String? Function(String?)? validator;
  final String hintText;
  final bool isEnabled;

  const Primarytextinputfield({
    super.key,
    required this.hintText,
    this.imeAction,
    this.keyboardType,
    this.isSecureTextField,
    this.validator,
    required this.ctrl,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
       controller: ctrl,
      keyboardType: keyboardType != null ? keyboardType:  TextInputType.text,
      textInputAction: imeAction != null ? imeAction : TextInputAction.done,
      obscureText: isSecureTextField != null ? isSecureTextField! : false,
      validator: validator,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal
      ),
      enabled: isEnabled,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.white,
        border:  OutlineInputBorder(
            borderSide:BorderSide(color:AppColors.secondBackground,width: 2),
          borderRadius: BorderRadius.circular(10)
        ),
        enabledBorder:  OutlineInputBorder(
            borderSide:BorderSide(color:AppColors.secondBackground,width: 2),
            borderRadius: BorderRadius.circular(10)


      ),
        focusedBorder:  OutlineInputBorder(
            borderSide:BorderSide(color:AppColors.secondBackground,width: 2),
            borderRadius: BorderRadius.circular(10)


        ),
      ),
    );
  }
}
