import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/core/network/api_client.dart';
import 'package:app_manager/core/navigation/router_helper.dart';
import 'package:app_manager/core/services/storage/i_token_storage.dart';
import 'package:app_manager/features/auth/data/repositories/auth_repository.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/navigation/router_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bootstrapAuth();
  }

  Future<void> _bootstrapAuth() async {
    _timer = Timer(const Duration(milliseconds: 1200), () async {
      final tokenStorage = getIt<ITokenStorage>();
      final apiClient = getIt<ApiClient>();
      final authRepository = getIt<IAuthRepository>();

      final accessToken = await tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        if (!mounted) return;
        goRoute(context, AppRoutes.login);
        return;
      }

      apiClient.setToken(accessToken);

      try {
        final me = await authRepository.getCurrentUser();
        if (!mounted) return;
        if (me.success) {
          goRoute(context, AppRoutes.adminDashboard);
        } else {
          await tokenStorage.clearTokens();
          apiClient.clearToken();
          if (!mounted) return;
          goRoute(context, AppRoutes.login);
        }
      } catch (_) {
        await tokenStorage.clearTokens();
        apiClient.clearToken();
        if (!mounted) return;
        goRoute(context, AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_rounded, size: 92, color: Colors.white),
                const SizedBox(height: 30),
                const Text(
                  'Hệ thống quản lý thương mại điện tử',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                _buildMemberCard('Lê Chí Nghĩa', '22110187'),
                const SizedBox(height: 12),
                _buildMemberCard('Lê Quốc Nam', '22110184'),
                const SizedBox(height: 50),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Đang kiểm tra phiên đăng nhập...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => goRoute(context, AppRoutes.login),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Bỏ qua'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(String name, String role) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.lock_outline_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(role, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
