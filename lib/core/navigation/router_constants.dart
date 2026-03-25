class AppRoutes {
  // Splash / auth flow
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // App-level
  static const String home = '/home';
  static const String error = '/not-found';
  static const String systemError = '/system-error';
  static const String forceUpdate = '/force-update';
  static const String noInternet = '/no-internet';
}
