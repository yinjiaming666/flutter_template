import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonWidget {
  static Widget btn({
    required double height,
    required String text,
    double? width,
    double fontSize = 16,
    double borderRadius = 8,
    FontWeight fontWeight = FontWeight.w600,
    Color color = const Color.fromRGBO(157, 117, 227, 1),
    Color textColor = Colors.white,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize.w,
          color: textColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  static Widget borderBtn({
    required Widget child,
    required double height,
    double? width,
    double borderRadius = 8,
    VoidCallback? onTap,
    Color borderColor = const Color.fromRGBO(157, 117, 227, 1),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }

  static Widget purpleText(String text, double fontSize, {double? height}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize.w,
        color: const Color.fromRGBO(157, 117, 227, 1),
        height: height,
      ),
    );
  }

  static Widget textInput(
    TextEditingController controller, {
    Widget? prefix,
    Widget? rightWidget,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    int? maxLength,
    String hintText = '',
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
  }) {
    return Container(
      width: width,
      height: height ?? 48.w,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(247, 247, 247, 1),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Row(
        children: [
          if (prefix != null) prefix,
          Expanded(
            child: TextField(
              enabled: enabled,
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                counterText: '',
                isCollapsed: true,
              ),
            ),
          ),
          if (rightWidget != null) rightWidget,
        ],
      ),
    );
  }
}
