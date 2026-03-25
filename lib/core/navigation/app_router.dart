import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_manager/core/navigation/router_constants.dart';
import 'package:app_manager/core/services/connectivity_service.dart';
import 'package:app_manager/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app_manager/features/auth/presentation/pages/login_page.dart';
import 'package:app_manager/features/auth/presentation/pages/register_page.dart';
import 'package:app_manager/features/auth/presentation/pages/reset_password_page.dart';
import 'package:app_manager/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:app_manager/features/auth/data/models/auth_models.dart';
import 'package:app_manager/features/home/presentation/pages/home_page.dart';
import 'package:app_manager/features/splash/presentation/pages/splash_page.dart';

GoRouter createAppRouter({
  required GlobalKey<NavigatorState> rootNavigatorKey,
  required ConnectivityService connectivityService,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: connectivityService.statusNotifier,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is RegisterFormData) {
            return VerifyOtpPage(formData: extra);
          }
          return const VerifyOtpPage(
            formData: RegisterFormData(
              email: '',
              password: '',
              confirmPassword: '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final extra = state.extra;
          return ResetPasswordPage(email: extra is String ? extra : '');
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.error,
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
}
