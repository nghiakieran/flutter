import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_manager/core/navigation/admin_shell_page.dart';
import 'package:app_manager/core/navigation/router_constants.dart';
import 'package:app_manager/core/services/connectivity_service.dart';
import 'package:app_manager/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:app_manager/features/admin/presentation/pages/admin_order_management_page.dart';
import 'package:app_manager/features/admin/presentation/pages/admin_product_management_page.dart';
import 'package:app_manager/features/admin/presentation/pages/admin_coupon_management_page.dart';
import 'package:app_manager/features/admin/presentation/pages/admin_profile_page.dart';
import 'package:app_manager/features/admin/presentation/pages/admin_reports_page.dart';
import 'package:app_manager/features/admin/presentation/pages/admin_review_management_page.dart';
import 'package:app_manager/features/admin/presentation/pages/admin_user_management_page.dart';
import 'package:app_manager/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app_manager/features/auth/presentation/pages/login_page.dart';
import 'package:app_manager/features/auth/presentation/pages/register_page.dart';
import 'package:app_manager/features/auth/presentation/pages/reset_password_page.dart';
import 'package:app_manager/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:app_manager/features/auth/data/models/auth_models.dart';
import 'package:app_manager/features/home/presentation/pages/home_page.dart';
import 'package:app_manager/features/splash/presentation/pages/splash_page.dart';

CustomTransitionPage<void> _buildAdminTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 140),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuad,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0.02, 0),
        end: Offset.zero,
      ).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

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
      ShellRoute(
        builder: (context, state, child) =>
            AdminShellPage(currentRoute: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            pageBuilder: (context, state) => _buildAdminTransitionPage(
              state: state,
              child: const AdminDashboardPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminOrders,
            pageBuilder: (context, state) => _buildAdminTransitionPage(
              state: state,
              child: const AdminOrderManagementPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminProducts,
            pageBuilder: (context, state) {
              final tab = state.uri.queryParameters['tab'];
              final initialTab = tab == 'brand' ? 1 : 0;
              return _buildAdminTransitionPage(
                state: state,
                child: AdminProductManagementPage(initialTab: initialTab),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.adminUsers,
            pageBuilder: (context, state) => _buildAdminTransitionPage(
              state: state,
              child: const AdminUserManagementPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminCoupons,
            pageBuilder: (context, state) => _buildAdminTransitionPage(
              state: state,
              child: const AdminCouponManagementPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminReviews,
            pageBuilder: (context, state) => _buildAdminTransitionPage(
              state: state,
              child: const AdminReviewManagementPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminReports,
            pageBuilder: (context, state) => _buildAdminTransitionPage(
              state: state,
              child: const AdminReportsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminProfile,
            pageBuilder: (context, state) => _buildAdminTransitionPage(
              state: state,
              child: const AdminProfilePage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.error,
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
}
