import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:app_manager/constants/app_colors.dart';

class AuthPrimaryShell extends StatelessWidget {
  const AuthPrimaryShell({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.showBackButton = true,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthPrimaryAppBar(
                        title: title,
                        onBack: onBack,
                        showBackButton: showBackButton,
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthPrimaryAppBar extends StatelessWidget {
  const _AuthPrimaryAppBar({
    required this.title,
    this.onBack,
    required this.showBackButton,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 56,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: showBackButton
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                          onPressed: () {
                            if (!context.mounted) return;
                            if (onBack != null) {
                              onBack!();
                              return;
                            }
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }
}
