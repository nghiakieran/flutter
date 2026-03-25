import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/navigation/router_constants.dart';
import 'package:app_manager/shared/ui_kit/app_button.dart';

class AuthSuccessBottomSheet extends StatelessWidget {
  const AuthSuccessBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            tween: Tween<double>(begin: 0.8, end: 1.0),
            builder: (context, value, _) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF7FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: buttonText ?? 'Tiếp tục',
              onPressed: () {
                Navigator.of(context).pop();
                if (onButtonPressed != null) {
                  onButtonPressed!();
                  return;
                }
                context.go(AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showAuthSuccessBottomSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  String? buttonText,
  VoidCallback? onButtonPressed,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    useSafeArea: false,
    builder: (context) => AuthSuccessBottomSheet(
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    ),
  );
}
