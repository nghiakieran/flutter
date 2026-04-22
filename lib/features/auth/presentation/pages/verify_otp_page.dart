import 'dart:async';

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:app_manager/core/navigation/router_helper.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/navigation/router_constants.dart';
import 'package:app_manager/core/services/snack_bar_service.dart';
import 'package:app_manager/features/auth/data/models/auth_models.dart';
import 'package:app_manager/features/auth/presentation/pages/widgets/auth_primary_shell.dart';
import 'package:app_manager/features/auth/presentation/pages/widgets/auth_success_bottom_sheet.dart';
import 'package:app_manager/shared/ui_kit/app_button.dart';
import 'package:app_manager/shared/widgets/otp/otp_code_field.dart';
import 'package:app_manager/shared/widgets/loading/shimmer_skeleton.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/core/services/storage/i_token_storage.dart';
import 'package:app_manager/core/network/api_client.dart';
import 'package:app_manager/features/auth/data/repositories/auth_repository.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key, required this.formData});

  final RegisterFormData formData;

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpLength = 6;
  late String _otpValue = '';

  bool _isLoading = false;
  int _timerSeconds = 60;
  Timer? _timer;

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
    super.dispose();
  }

  Future<void> _onVerify() async {
    final code = _otpValue.trim();
    if (code.length < _otpLength) return;

    setState(() => _isLoading = true);
    try {
      final response = await getIt<IAuthRepository>().verifyOtp(
        widget.formData.email,
        _otpValue,
        'REGISTER',
        widget.formData.role,
      );

      if (!mounted) return;

      if (response.success) {
        if (!context.mounted) return;
        if (response.token != null) {
          await getIt<ITokenStorage>().storeTokens(
            accessToken: response.token!,
            refreshToken: '',
          );
          getIt<ApiClient>().setToken(response.token!);
        }
        final currentContext = SnackBarService.scaffoldKey.currentContext;
        if (currentContext == null) return;
        showAuthSuccessBottomSheet(
          context: currentContext,
          title: 'Đăng ký thành công',
          subtitle:
              'Tài khoản của bạn đã được xác minh. Bạn có thể bắt đầu sử dụng ứng dụng ngay bây giờ.',
          buttonText: 'Đi tới Dashboard',
          onButtonPressed: () {
            final navContext = SnackBarService.scaffoldKey.currentContext;
            if (navContext == null) return;
            goRoute(navContext, AppRoutes.adminDashboard);
          },
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
        content: 'Xác minh OTP thất bại. Vui lòng thử lại.',
        status: StatusSnackBar.error,
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
        widget.formData.email,
        'REGISTER',
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
    final canVerify = !_isLoading && _otpValue.length == _otpLength;

    return AuthPrimaryShell(
      title: 'Xác minh OTP',
      showBackButton: true,
      onBack: () => goBack(context),
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
                widget.formData.email,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
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
              if (_isLoading) ...[
                const SizedBox(height: 14),
                const ShimmerSkeleton(height: 14, width: 260, radius: 16),
                const SizedBox(height: 10),
                const ShimmerSkeleton(height: 14, width: 180, radius: 16),
              ],
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Nhập mã gồm 6 chữ số để tiếp tục.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: _timerSeconds == 0 && !_isLoading
                      ? _onResend
                      : null,
                  child: Text(
                    _timerSeconds > 0
                        ? 'Gửi lại sau ${_timerSeconds}s'
                        : 'Gửi lại OTP',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _timerSeconds > 0
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontWeight: _timerSeconds > 0
                          ? FontWeight.w600
                          : FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Xác nhận',
                loading: _isLoading,
                disabled: !canVerify,
                onPressed: _onVerify,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
