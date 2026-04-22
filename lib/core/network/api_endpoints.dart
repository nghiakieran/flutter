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

  // Admin endpoints
  static const String adminDashboard = '/api/v1/admin/dashboard';
  static const String adminOrders = '/api/v1/admin/orders';
  static const String adminProducts = '/api/v1/admin/products';
  static const String adminBrands = '/api/v1/admin/brands';
  static const String adminUsers = '/api/v1/admin/users';
  static const String adminStaffs = '/api/v1/admin/staffs';
  static const String adminCoupons = '/api/v1/admin/coupons';
  static const String adminReviews = '/api/v1/admin/reviews';
  static const String adminReportSummary = '/api/v1/admin/reports/summary';
  static const String adminReportExport = '/api/v1/admin/reports/export';
}
