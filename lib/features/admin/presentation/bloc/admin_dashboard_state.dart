import 'package:app_manager/features/admin/data/models/admin_dashboard_models.dart';

class AdminDashboardState {
  const AdminDashboardState({
    this.isLoading = false,
    this.summary,
    this.errorMessage,
  });

  final bool isLoading;
  final AdminDashboardSummary? summary;
  final String? errorMessage;

  AdminDashboardState copyWith({
    bool? isLoading,
    AdminDashboardSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminDashboardState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
