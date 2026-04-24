import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/services/base_service.dart';
import 'package:app_manager/features/admin/coupons/data/models/admin_coupon_models.dart';

abstract class IAdminCouponRepository {
  Future<Result<AdminCouponPage>> getCoupons({
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Result<void>> createCoupon({
    required String code,
    required String type,
    required double value,
    required double minOrderValue,
    double? maxDiscountValue,
    required String startDateIso,
    required String endDateIso,
    required int usageLimit,
    required bool isActive,
  });
  Future<Result<void>> updateCoupon({
    required int id,
    required String code,
    required String type,
    required double value,
    required double minOrderValue,
    double? maxDiscountValue,
    required String startDateIso,
    required String endDateIso,
    required int usageLimit,
    required bool isActive,
  });
  Future<Result<void>> deleteCoupon(int id);
}

class AdminCouponRepository extends BaseService
    implements IAdminCouponRepository {
  AdminCouponRepository({
    required super.apiClient,
    required super.tokenStorage,
  });

  @override
  Future<Result<AdminCouponPage>> getCoupons({
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return executeRequest<AdminCouponPage>(
      request: () => apiClient.dio.get(
        ApiEndpoints.adminCoupons,
        queryParameters: {
          'page': page,
          'limit': limit,
          'sort': '-createdAt',
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
        return AdminCouponPage(
          items: data
              .whereType<Map<String, dynamic>>()
              .map(AdminCoupon.fromJson)
              .toList(),
          page: int.tryParse(pagination['page']?.toString() ?? '') ?? page,
          limit: int.tryParse(pagination['limit']?.toString() ?? '') ?? limit,
          total: int.tryParse(pagination['total']?.toString() ?? '') ?? 0,
          totalPages:
              int.tryParse(pagination['totalPages']?.toString() ?? '') ?? 1,
        );
      },
    );
  }

  @override
  Future<Result<void>> createCoupon({
    required String code,
    required String type,
    required double value,
    required double minOrderValue,
    double? maxDiscountValue,
    required String startDateIso,
    required String endDateIso,
    required int usageLimit,
    required bool isActive,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.post(
        ApiEndpoints.adminCoupons,
        data: {
          'code': code,
          'type': type,
          'value': value,
          'minOrderValue': minOrderValue,
          'maxDiscountValue': maxDiscountValue,
          'startDate': startDateIso,
          'endDate': endDateIso,
          'usageLimit': usageLimit,
          'isActive': isActive,
        },
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> updateCoupon({
    required int id,
    required String code,
    required String type,
    required double value,
    required double minOrderValue,
    double? maxDiscountValue,
    required String startDateIso,
    required String endDateIso,
    required int usageLimit,
    required bool isActive,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.put(
        '${ApiEndpoints.adminCoupons}/$id',
        data: {
          'code': code,
          'type': type,
          'value': value,
          'minOrderValue': minOrderValue,
          'maxDiscountValue': maxDiscountValue,
          'startDate': startDateIso,
          'endDate': endDateIso,
          'usageLimit': usageLimit,
          'isActive': isActive,
        },
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> deleteCoupon(int id) {
    return executeRequest<void>(
      request: () => apiClient.dio.delete('${ApiEndpoints.adminCoupons}/$id'),
      parser: (_) {},
    );
  }
}
