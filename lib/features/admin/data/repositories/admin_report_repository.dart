import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/services/base_service.dart';
import 'package:app_manager/features/admin/data/models/admin_report_models.dart';

abstract class IAdminReportRepository {
  Future<Result<AdminReportSummary>> getSummary({
    required String period,
    String? from,
    String? to,
  });
  Future<Result<String>> exportContent({
    required String format,
    required String period,
    String? from,
    String? to,
  });
}

class AdminReportRepository extends BaseService
    implements IAdminReportRepository {
  AdminReportRepository({
    required super.apiClient,
    required super.tokenStorage,
  });

  @override
  Future<Result<AdminReportSummary>> getSummary({
    required String period,
    String? from,
    String? to,
  }) {
    return executeRequest<AdminReportSummary>(
      request: () => apiClient.dio.get(
        ApiEndpoints.adminReportSummary,
        queryParameters: {
          'period': period,
          if (from != null && from.isNotEmpty) 'from': from,
          if (to != null && to.isNotEmpty) 'to': to,
        },
      ),
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return AdminReportSummary.fromJson(data);
        }
        if (data is Map) {
          return AdminReportSummary.fromJson(
            data.map((key, value) => MapEntry(key.toString(), value)),
          );
        }
        return AdminReportSummary.fromJson(const <String, dynamic>{});
      },
    );
  }

  @override
  Future<Result<String>> exportContent({
    required String format,
    required String period,
    String? from,
    String? to,
  }) {
    return executeRequest<String>(
      request: () => apiClient.dio.get(
        ApiEndpoints.adminReportExport,
        queryParameters: {
          'format': format,
          'period': period,
          if (from != null && from.isNotEmpty) 'from': from,
          if (to != null && to.isNotEmpty) 'to': to,
        },
      ),
      parser: (data) => data?.toString() ?? '',
    );
  }
}
