import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/services/base_service.dart';
import 'package:app_manager/features/admin/data/models/admin_dashboard_models.dart';

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
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return AdminDashboardSummary.fromJson(data);
        }
        if (data is Map) {
          return AdminDashboardSummary.fromJson(
            data.map((key, value) => MapEntry(key.toString(), value)),
          );
        }
        return const AdminDashboardSummary(
          todayRevenue: DashboardMetricCard(
            label: 'Revenue (Day)',
            value: 0,
            delta: 0,
          ),
          monthRevenue: DashboardMetricCard(
            label: 'Revenue (Month)',
            value: 0,
            delta: 0,
          ),
          yearRevenue: DashboardMetricCard(
            label: 'Revenue (Year)',
            value: 0,
            delta: 0,
          ),
          totalUsers: 0,
          orderByStatus: <DashboardOrderStatusMetric>[],
        );
      },
      customErrorMessage: 'Unable to load dashboard summary',
    );
  }
}
