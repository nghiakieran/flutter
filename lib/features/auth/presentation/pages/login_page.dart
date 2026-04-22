import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/navigation/router_constants.dart';
import 'package:app_manager/core/navigation/router_helper.dart';
import 'package:app_manager/features/auth/presentation/pages/widgets/auth_primary_shell.dart';
import 'package:app_manager/shared/ui_kit/app_button.dart';
import 'package:app_manager/shared/ui_kit/app_input.dart';
import 'package:app_manager/shared/widgets/error-empty/error_state_widget.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/auth/data/repositories/auth_repository.dart';
import 'package:app_manager/features/auth/data/models/auth_models.dart';
import 'package:app_manager/core/services/storage/i_token_storage.dart';
import 'package:app_manager/core/network/api_client.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) => v.contains('@') && v.contains('.');

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _errorMessage = null);

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Vui lòng nhập email hợp lệ.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await getIt<IAuthRepository>().login(
        email,
        password,
        'ADMIN',
      );

      if (!mounted) return;

      if (response.success) {
        if (response.token != null) {
          final token = response.token!;
          await getIt<ITokenStorage>().storeTokens(
            accessToken: token,
            refreshToken: '',
          );
          if (!mounted) return;
          getIt<ApiClient>().setToken(token);
        }
        goRoute(context, AppRoutes.adminDashboard);
      } else {
        if (response.code == 'ACCOUNT_NOT_VERIFIED' && response.email != null) {
          pushRoute(
            context,
            AppRoutes.verifyOtp,
            extra: RegisterFormData(
              email: response.email!,
              password: password,
              confirmPassword: password,
            ),
          );
          return;
        }
        setState(() => _errorMessage = response.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Đăng nhập thất bại. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _emailController.text.trim();
    final canSubmit =
        !_isLoading && email.isNotEmpty && _passwordController.text.isNotEmpty;

    return AuthPrimaryShell(
      title: 'Đăng nhập',
      showBackButton: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Nhập email của bạn',
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  } else {
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 24),
              AppInput(
                controller: _passwordController,
                labelText: 'Mật khẩu',
                hintText: 'Nhập mật khẩu của bạn',
                obscureText: _obscurePassword,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                  setState(() {});
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() {
                    _obscurePassword = !_obscurePassword;
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onChanged: (v) =>
                          setState(() => _rememberMe = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ghi nhớ đăng nhập',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        pushRoute(context, AppRoutes.forgotPassword),
                    child: const Text('Quên mật khẩu'),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                ErrorStateWidget(
                  title: 'Lỗi xác thực',
                  message: _errorMessage!,
                ),
                const SizedBox(height: 8),
              ],
              const Spacer(),
              AppButton(
                text: 'Đăng nhập',
                loading: _isLoading,
                disabled: !canSubmit,
                onPressed: _onLogin,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => pushRoute(context, AppRoutes.register),
                    child: const Text('Đăng ký'),
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
