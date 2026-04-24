import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/services/base_service.dart';
import 'package:app_manager/features/admin/dashboard/data/models/admin_dashboard_models.dart';

abstract class IAdminDashboardRepository {
  Future<Result<AdminDashboardSummary>> getDashboardSummary();
}

class AdminDashboardRepository extends BaseService
    implements IAdminDashboardRepository {
  AdminDashboardRepository({
    required super.apiClient,
    required super.tokenStorage,
  });

  @override
  Future<Result<AdminDashboardSummary>> getDashboardSummary() {
    return executeRequest<AdminDashboardSummary>(
      request: () => apiClient.dio.get(ApiEndpoints.adminDashboard),
      parser: (raw) {
        try {
          final response = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
          final data = response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : <String, dynamic>{};
          return AdminDashboardSummary.fromJson(data);
        } catch (e) {
          return const AdminDashboardSummary(
            todayRevenue: DashboardMetricCard(label: 'Revenue (Day)', value: 0, delta: 0),
            monthRevenue: DashboardMetricCard(label: 'Revenue (Month)', value: 0, delta: 0),
            yearRevenue: DashboardMetricCard(label: 'Revenue (Year)', value: 0, delta: 0),
            totalUsers: 0,
            orderByStatus: [],
          );
        }
      },
      customErrorMessage: 'Unable to load dashboard summary',
    );
  }
}
