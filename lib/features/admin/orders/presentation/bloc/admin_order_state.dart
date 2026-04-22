import 'package:app_manager/features/admin/orders/data/models/admin_order_models.dart';

class AdminOrderState {
  const AdminOrderState({
    this.isLoading = false,
    this.items = const <AdminOrderItem>[],
    this.errorMessage,
    this.statusFilter = '',
    this.search = '',
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 1,
  });

  final bool isLoading;
  final List<AdminOrderItem> items;
  final String? errorMessage;
  final String statusFilter;
  final String search;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  AdminOrderState copyWith({
    bool? isLoading,
    List<AdminOrderItem>? items,
    String? errorMessage,
    String? statusFilter,
    String? search,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool clearError = false,
  }) {
    return AdminOrderState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusFilter: statusFilter ?? this.statusFilter,
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
