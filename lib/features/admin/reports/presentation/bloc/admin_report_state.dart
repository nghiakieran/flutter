import 'package:app_manager/features/admin/reports/data/models/admin_report_models.dart';

class AdminReportState {
  const AdminReportState({
    this.isLoading = false,
    this.summary,
    this.errorMessage,
    this.period = 'month',
  });

  final bool isLoading;
  final AdminReportSummary? summary;
  final String? errorMessage;
  final String period;

  AdminReportState copyWith({
    bool? isLoading,
    AdminReportSummary? summary,
    String? errorMessage,
    String? period,
    bool clearError = false,
  }) {
    return AdminReportState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      period: period ?? this.period,
    );
  }
}
