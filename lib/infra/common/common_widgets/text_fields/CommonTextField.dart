import 'package:flutter/material.dart';

class CommontextField extends StatelessWidget {
  final String contentText;
  final FontWeight fontWeight;
  final double fontSize;
  const CommontextField({
  super.key,
    required this.contentText,
    required this.fontWeight,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(contentText,style: TextStyle(fontWeight:fontWeight,fontSize: fontSize ));
  }
}
