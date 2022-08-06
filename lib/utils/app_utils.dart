import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';



class AppUtils{
  AppUtils._privateConstructor();
  static final AppUtils instance = AppUtils._privateConstructor();

  void showToast({String? toastMessage, Color? backgroundColor, Color? textColor}) {
    Fluttertoast.showToast(
        msg: toastMessage!,
        // backgroundColor: backgroundColor ?? AppColor.blue,
        // textColor: textColor ?? AppColor.white,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }
}