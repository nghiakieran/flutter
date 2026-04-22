import 'package:app_manager/features/admin/data/models/admin_review_models.dart';

class AdminReviewState {
  const AdminReviewState({
    this.isLoading = false,
    this.reviews = const <AdminReview>[],
    this.errorMessage,
    this.search = '',
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 1,
  });

  final bool isLoading;
  final List<AdminReview> reviews;
  final String? errorMessage;
  final String search;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  AdminReviewState copyWith({
    bool? isLoading,
    List<AdminReview>? reviews,
    String? errorMessage,
    String? search,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool clearError = false,
  }) {
    return AdminReviewState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
