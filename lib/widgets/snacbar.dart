import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.blue,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    String? actionLabel,
    VoidCallback? onActionPressed,
    double? margin,
    double? width,
    ShapeBorder? shape,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? textStyle,
    Widget? icon,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            icon,
            SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: textStyle ?? TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: behavior,
      margin: margin != null ? EdgeInsets.all(margin) : null,
      width: width,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      action: actionLabel != null
          ? SnackBarAction(
        label: actionLabel,
        textColor: textColor,
        onPressed: onActionPressed ?? () {},
      )
          : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // With icons
  static void successWithIcon({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icon(Icons.check_circle, color: Colors.white, size: 20),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void errorWithIcon({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icon(Icons.error, color: Colors.white, size: 20),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void warningWithIcon({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icon(Icons.warning, color: Colors.white, size: 20),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  // Floating snackbar with custom position
  static void showFloating({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.blue,
    Alignment alignment = Alignment.bottomCenter,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: 8,
    );
  }
}