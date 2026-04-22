import 'package:app_manager/features/admin/coupons/data/models/admin_coupon_models.dart';

class AdminCouponState {
  const AdminCouponState({
    this.isLoading = false,
    this.coupons = const <AdminCoupon>[],
    this.errorMessage,
    this.search = '',
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 1,
  });

  final bool isLoading;
  final List<AdminCoupon> coupons;
  final String? errorMessage;
  final String search;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  AdminCouponState copyWith({
    bool? isLoading,
    List<AdminCoupon>? coupons,
    String? errorMessage,
    String? search,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool clearError = false,
  }) {
    return AdminCouponState(
      isLoading: isLoading ?? this.isLoading,
      coupons: coupons ?? this.coupons,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
