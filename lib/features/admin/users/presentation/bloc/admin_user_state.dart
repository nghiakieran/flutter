import 'package:app_manager/features/admin/users/data/models/admin_user_models.dart';

class AdminUserState {
  const AdminUserState({
    this.isLoading = false,
    this.customers = const <AdminUser>[],
    this.staffs = const <AdminUser>[],
    this.errorMessage,
    this.customerSearch = '',
    this.staffSearch = '',
    this.customerPage = 1,
    this.customerLimit = 10,
    this.customerTotal = 0,
    this.customerTotalPages = 1,
    this.staffPage = 1,
    this.staffLimit = 10,
    this.staffTotal = 0,
    this.staffTotalPages = 1,
  });

  final bool isLoading;
  final List<AdminUser> customers;
  final List<AdminUser> staffs;
  final String? errorMessage;
  final String customerSearch;
  final String staffSearch;
  final int customerPage;
  final int customerLimit;
  final int customerTotal;
  final int customerTotalPages;
  final int staffPage;
  final int staffLimit;
  final int staffTotal;
  final int staffTotalPages;

  AdminUserState copyWith({
    bool? isLoading,
    List<AdminUser>? customers,
    List<AdminUser>? staffs,
    String? errorMessage,
    String? customerSearch,
    String? staffSearch,
    int? customerPage,
    int? customerLimit,
    int? customerTotal,
    int? customerTotalPages,
    int? staffPage,
    int? staffLimit,
    int? staffTotal,
    int? staffTotalPages,
    bool clearError = false,
  }) {
    return AdminUserState(
      isLoading: isLoading ?? this.isLoading,
      customers: customers ?? this.customers,
      staffs: staffs ?? this.staffs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      customerSearch: customerSearch ?? this.customerSearch,
      staffSearch: staffSearch ?? this.staffSearch,
      customerPage: customerPage ?? this.customerPage,
      customerLimit: customerLimit ?? this.customerLimit,
      customerTotal: customerTotal ?? this.customerTotal,
      customerTotalPages: customerTotalPages ?? this.customerTotalPages,
      staffPage: staffPage ?? this.staffPage,
      staffLimit: staffLimit ?? this.staffLimit,
      staffTotal: staffTotal ?? this.staffTotal,
      staffTotalPages: staffTotalPages ?? this.staffTotalPages,
    );
  }
}
