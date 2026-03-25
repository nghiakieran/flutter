class ApiEndpoints {
  ApiEndpoints._();

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resendOtp = '/api/auth/resend-otp';
  static const String forgotPassword = '/api/auth/forget-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String me = '/api/auth/me';
  static const String refreshToken = '/api/auth/refresh-token';
}
