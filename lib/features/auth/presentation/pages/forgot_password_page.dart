import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_manager/core/navigation/router_helper.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/navigation/router_constants.dart';
import 'package:app_manager/features/auth/presentation/pages/widgets/auth_primary_shell.dart';
import 'package:app_manager/shared/ui_kit/app_button.dart';
import 'package:app_manager/shared/ui_kit/app_input.dart';
import 'package:app_manager/shared/widgets/error-empty/empty_state_widget.dart';
import 'package:app_manager/shared/widgets/loading/shimmer_skeleton.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/auth/data/repositories/auth_repository.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool _isValidEmail(String v) => v.contains('@') && v.contains('.');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final email = _emailController.text.trim();
    setState(() => _errorMessage = null);

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Vui lòng nhập email hợp lệ.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await getIt<IAuthRepository>().forgotPassword(email);

      if (!mounted) return;

      if (response.success) {
        pushRoute(context, AppRoutes.resetPassword, extra: email);
      } else {
        setState(() => _errorMessage = response.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Không thể gửi OTP. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _emailController.text.trim();
    final showEmpty = email.isEmpty && _errorMessage == null;

    return AuthPrimaryShell(
      title: 'Quên mật khẩu',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showEmpty) ...[
                EmptyStateWidget(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Khôi phục bằng OTP',
                  message:
                      'Chúng tôi sẽ gửi một mã OTP bảo mật để xác minh email của bạn.',
                  action: const SizedBox.shrink(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              AppInput(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Nhập email của bạn',
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Spacer(),
              if (_isLoading) ...[
                const ShimmerSkeleton(height: 14, width: 240, radius: 16),
                const SizedBox(height: 12),
              ],
              AppButton(
                text: 'Gửi OTP',
                loading: _isLoading,
                disabled: !_isValidEmail(email) || _isLoading,
                onPressed: _onContinue,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã nhớ mật khẩu?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => goRoute(context, AppRoutes.login),
                    child: const Text('Quay lại đăng nhập'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
