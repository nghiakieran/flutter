import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_manager/core/navigation/router_helper.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/navigation/router_constants.dart';
import 'package:app_manager/features/auth/data/models/auth_models.dart';
import 'package:app_manager/features/auth/presentation/pages/widgets/auth_primary_shell.dart';
import 'package:app_manager/shared/ui_kit/app_button.dart';
import 'package:app_manager/shared/ui_kit/app_input.dart';
import 'package:app_manager/shared/widgets/error-empty/empty_state_widget.dart';
import 'package:app_manager/shared/widgets/loading/shimmer_skeleton.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/auth/data/repositories/auth_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) => v.contains('@') && v.contains('.');

  bool get _canSubmit {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    return !_isLoading &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirm.isNotEmpty &&
        _isValidEmail(email) &&
        password.length >= 6 &&
        confirm == password &&
        _agreeToTerms;
  }

  Future<void> _onContinue() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    setState(() => _errorMessage = null);

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Vui lòng nhập email hợp lệ.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }
    if (confirm != password) {
      setState(() => _errorMessage = 'Mật khẩu không khớp.');
      return;
    }
    if (!_agreeToTerms) {
      setState(
        () => _errorMessage = 'Vui lòng chấp nhận Điều khoản & Quyền riêng tư.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await getIt<IAuthRepository>().register(
        _nameController.text.trim(),
        email,
        password,
        'ADMIN',
      );

      if (!mounted) return;

      if (response.success) {
        pushRoute(
          context,
          AppRoutes.verifyOtp,
          extra: RegisterFormData(
            email: email,
            password: password,
            confirmPassword: confirm,
            name: _nameController.text.trim(),
            role: 'ADMIN',
          ),
        );
      } else {
        setState(() => _errorMessage = response.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Đăng ký thất bại. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final showEmpty =
        name.isEmpty && email.isEmpty && password.isEmpty && confirm.isEmpty;

    return AuthPrimaryShell(
      title: 'Đăng ký',
      showBackButton: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 16,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showEmpty) ...[
                        EmptyStateWidget(
                          icon: Icons.lock_outline_rounded,
                          title: 'Bắt đầu đăng ký an toàn',
                          message:
                              'Nhập email của bạn và tạo mật khẩu. Chúng tôi sẽ xác minh bằng OTP.',
                          action: const SizedBox.shrink(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ],
                      AppInput(
                        controller: _nameController,
                        labelText: 'Họ và tên',
                        hintText: 'Nhập họ và tên của bạn',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
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
                      AppInput(
                        controller: _passwordController,
                        labelText: 'Mật khẩu',
                        hintText: 'Tạo mật khẩu mạnh',
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
                      AppInput(
                        controller: _confirmPasswordController,
                        labelText: 'Xác nhận mật khẩu',
                        hintText: 'Nhập lại mật khẩu',
                        obscureText: _obscureConfirmPassword,
                        onChanged: (_) {
                          if (_errorMessage != null) {
                            setState(() => _errorMessage = null);
                          }
                          setState(() {});
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TermsRow(
                        value: _agreeToTerms,
                        onChanged: (v) => setState(() => _agreeToTerms = v),
                      ),
                      if (_isLoading) ...[
                        const SizedBox(height: 16),
                        const ShimmerSkeleton(
                          height: 16,
                          width: 220,
                          radius: 16,
                        ),
                        const SizedBox(height: 10),
                        const ShimmerSkeleton(
                          height: 16,
                          width: 280,
                          radius: 16,
                        ),
                      ],
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                      const Spacer(),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Tiếp tục',
                        loading: _isLoading,
                        disabled: !_canSubmit,
                        onPressed: _onContinue,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bạn đã có tài khoản?',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () => goRoute(context, AppRoutes.login),
                            child: const Text('Đăng nhập'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.border,
                width: value ? 2 : 1,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.primary,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tôi đồng ý với Điều khoản & Quyền riêng tư',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
