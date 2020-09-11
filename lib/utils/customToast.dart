import 'package:Arrive/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  static const toastLength = Toast.LENGTH_SHORT;
  static const gravity = ToastGravity.BOTTOM;
  static const timeInSecForIosWeb = 2;
  static const textColor = Colors.white;
  static const fontSize = 16.0;

  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: timeInSecForIosWeb,
      backgroundColor: kDangerColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: timeInSecForIosWeb,
      backgroundColor: kPrimaryColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}
