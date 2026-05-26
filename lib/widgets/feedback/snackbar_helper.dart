import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class SnackBarHelper {
  const SnackBarHelper._();

  static void showError(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 4),
      }) {
    _show(
      context,
      message: message,
      backgroundColor: LightTheme.danger,
      icon: Icons.error_outline_rounded,
      duration: duration,
    );
  }

  static void showSuccess(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    _show(
      context,
      message: message,
      backgroundColor: LightTheme.primaryDark,
      icon: Icons.check_circle_outline_rounded,
      duration: duration,
    );
  }

  static void showInfo(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    _show(
      context,
      message: message,
      backgroundColor: LightTheme.primary,
      icon: Icons.info_outline_rounded,
      duration: duration,
    );
  }

  static void showWarning(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 4),
      }) {
    _show(
      context,
      message: message,
      backgroundColor: LightTheme.amber,
      icon: Icons.warning_amber_rounded,
      duration: duration,
    );
  }

  static void _show(
      BuildContext context, {
        required String message,
        required Color backgroundColor,
        required IconData icon,
        required Duration duration,
      }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: duration,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}