import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/services/base_service.dart';
import 'package:app_manager/features/admin/data/models/admin_order_models.dart';

abstract class IAdminOrderRepository {
  Future<Result<AdminOrderPage>> getOrders({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Result<void>> updateOrderStatus({
    required int orderId,
    required String status,
  });
}

class AdminOrderRepository extends BaseService
    implements IAdminOrderRepository {
  AdminOrderRepository({required super.apiClient, required super.tokenStorage});

  @override
  Future<Result<AdminOrderPage>> getOrders({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return executeRequest<AdminOrderPage>(
      request: () => apiClient.dio.get(
        ApiEndpoints.adminOrders,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null && status.isNotEmpty) 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      ),
      parser: (raw) {
        final response = raw is Map<String, dynamic>
            ? raw
            : <String, dynamic>{};
        final data = response['data'] is List
            ? response['data'] as List
            : const [];
        final pagination = response['pagination'] is Map<String, dynamic>
            ? response['pagination'] as Map<String, dynamic>
            : <String, dynamic>{};
        return AdminOrderPage(
          items: data
              .whereType<Map<String, dynamic>>()
              .map(AdminOrderItem.fromJson)
              .toList(),
          page: int.tryParse(pagination['page']?.toString() ?? '') ?? page,
          limit: int.tryParse(pagination['limit']?.toString() ?? '') ?? limit,
          total: int.tryParse(pagination['total']?.toString() ?? '') ?? 0,
          totalPages:
              int.tryParse(pagination['totalPages']?.toString() ?? '') ?? 1,
        );
      },
      customErrorMessage: 'Unable to load admin orders',
    );
  }

  @override
  Future<Result<void>> updateOrderStatus({
    required int orderId,
    required String status,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.put(
        '${ApiEndpoints.adminOrders}/$orderId/status',
        data: {'status': status},
      ),
      parser: (_) {},
      customErrorMessage: 'Unable to update order status',
    );
  }
}
