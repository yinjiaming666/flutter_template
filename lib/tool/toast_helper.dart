import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void showToast({
    required String msg,
    String channel = 'default',
    int untilSeconds = 2,
  }) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: untilSeconds,
    );
  }
}
