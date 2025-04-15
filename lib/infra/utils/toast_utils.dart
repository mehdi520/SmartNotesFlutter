
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void showSuccess(String message) {
    _showToast(message, backgroundColor: Colors.green);
  }

  static void showError(String message) {
    _showToast(message, backgroundColor: Colors.red);
  }

  static void showInfo(String message) {
    _showToast(message, backgroundColor: Colors.blueGrey);
  }

  static void _showToast(String message, {Color backgroundColor = Colors.black}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
