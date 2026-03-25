import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_manager/core/navigation/router_helper.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/navigation/router_constants.dart';
import 'package:app_manager/core/services/snack_bar_service.dart';
import 'package:app_manager/features/auth/presentation/pages/widgets/auth_primary_shell.dart';
import 'package:app_manager/features/auth/presentation/pages/widgets/auth_success_bottom_sheet.dart';
import 'package:app_manager/shared/ui_kit/app_button.dart';
import 'package:app_manager/shared/ui_kit/app_input.dart';
import 'package:app_manager/shared/widgets/otp/otp_code_field.dart';
import 'package:app_manager/shared/widgets/loading/shimmer_skeleton.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/auth/data/repositories/auth_repository.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _otpLength = 6;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _otpValue = '';
  int _timerSeconds = 60;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timerSeconds <= 0) {
        t.cancel();
        return;
      }
      setState(() => _timerSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidPassword(String v) => v.length >= 6;

  Future<void> _onReset() async {
    setState(() => _errorMessage = null);

    final otp = _otpValue.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (otp.length < _otpLength) {
      setState(() => _errorMessage = 'Vui lòng nhập đầy đủ mã OTP.');
      return;
    }
    if (!_isValidPassword(password)) {
      setState(() => _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Mật khẩu không khớp.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Step 1: Verify OTP to get resetToken
      final verifyResponse = await getIt<IAuthRepository>().verifyOtp(
        widget.email,
        otp,
        'RESET_PASSWORD',
        'ADMIN',
      );

      if (!mounted) return;

      if (!verifyResponse.success || verifyResponse.resetToken == null) {
        setState(() => _errorMessage = verifyResponse.message);
        return;
      }

      // Step 2: Use resetToken to update password
      final resetResponse = await getIt<IAuthRepository>().resetPassword(
        verifyResponse.resetToken!,
        password,
      );

      if (!mounted) return;

      if (resetResponse.success) {
        showAuthSuccessBottomSheet(
          context: context,
          title: 'Cập nhật mật khẩu thành công',
          subtitle: 'Bạn có thể đăng nhập với mật khẩu mới.',
          buttonText: 'Quay lại Đăng nhập',
          onButtonPressed: () {
            goRoute(context, AppRoutes.login);
          },
        );
      } else {
        setState(() => _errorMessage = resetResponse.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Đặt lại mật khẩu thất bại. Vui lòng thử lại.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onResend() async {
    if (_timerSeconds > 0) return;
    setState(() => _isLoading = true);
    try {
      final response = await getIt<IAuthRepository>().resendOtp(
        widget.email,
        'RESET_PASSWORD',
      );

      if (!mounted) return;

      if (response.success) {
        _startTimer();
        SnackBarService.showSnackBar(
          content: response.message,
          status: StatusSnackBar.success,
        );
      } else {
        SnackBarService.showSnackBar(
          content: response.message,
          status: StatusSnackBar.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarService.showSnackBar(
        content: 'Không thể gửi lại OTP. Vui lòng thử lại sau.',
        status: StatusSnackBar.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canReset =
        !_isLoading &&
        _otpValue.length == _otpLength &&
        _isValidPassword(_passwordController.text) &&
        _passwordController.text == _confirmPasswordController.text;

    return AuthPrimaryShell(
      title: 'Đặt lại mật khẩu',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'OTP đã được gửi đến email của bạn',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
              OtpCodeField(
                length: _otpLength,
                initialValue: '',
                enabled: !_isLoading,
                onChanged: (v) {
                  _otpValue = v;
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _timerSeconds > 0
                          ? 'Bạn có thể gửi lại OTP sau $_timerSeconds giây'
                          : 'Bạn có thể gửi lại OTP ngay bây giờ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _timerSeconds == 0 && !_isLoading
                        ? _onResend
                        : null,
                    child: Text(
                      'Gửi lại',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _timerSeconds == 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_isLoading) ...[
                const ShimmerSkeleton(height: 14, width: 220, radius: 16),
                const SizedBox(height: 12),
              ],
              AppInput(
                controller: _passwordController,
                labelText: 'Mật khẩu mới',
                hintText: 'Nhập mật khẩu mới',
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
              const SizedBox(height: 24),
              AppInput(
                controller: _confirmPasswordController,
                labelText: 'Xác nhận mật khẩu mới',
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
              const Spacer(),
              AppButton(
                text: 'Cập nhật mật khẩu',
                loading: _isLoading,
                disabled: !canReset,
                onPressed: _onReset,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
