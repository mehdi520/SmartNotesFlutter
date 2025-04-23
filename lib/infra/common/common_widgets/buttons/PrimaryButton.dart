import 'package:flutter/material.dart';
import 'package:note_book/infra/core/configs/theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final Color? bgColor;
  final void Function() onTap;
  const PrimaryButton({super.key, required this.text, required this.onTap , this.bgColor});


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor:  bgColor == null ?  AppColors.primary : bgColor ,
            foregroundColor: AppColors.white,
            minimumSize: Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Corner radius
            ),// Width, Height
          ),
          child: Text(text,style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16
          ),)),
    );
  }
}
