import 'package:flutter/material.dart';

enum StatusSnackBar { success, error, warning, info }

class SnackBarService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar({
    required String content,
    StatusSnackBar status = StatusSnackBar.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final Color backgroundColor;
    final IconData iconData;

    switch (status) {
      case StatusSnackBar.success:
        backgroundColor = const Color(0xFF4CAF50);
        iconData = Icons.check_circle_outline;
        break;
      case StatusSnackBar.error:
        backgroundColor = const Color(0xFFE53935);
        iconData = Icons.error_outline;
        break;
      case StatusSnackBar.warning:
        backgroundColor = const Color(0xFFFFA000);
        iconData = Icons.warning_amber_rounded;
        break;
      case StatusSnackBar.info:
        backgroundColor = const Color(0xFF1976D2);
        iconData = Icons.info_outline;
        break;
    }

    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(content, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
