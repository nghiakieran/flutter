import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/services/base_service.dart';
import 'package:app_manager/features/admin/users/data/models/admin_user_models.dart';

abstract class IAdminUserRepository {
  Future<Result<AdminUserPage>> getUsers({
    required String role,
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Result<void>> setUserVerified({
    required int id,
    required bool isVerified,
  });
  Future<Result<void>> createStaff({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<Result<void>> updateStaff({
    required int id,
    required String name,
    String? phone,
    bool? isVerified,
  });
  Future<Result<void>> deleteStaff(int id);
}

class AdminUserRepository extends BaseService implements IAdminUserRepository {
  AdminUserRepository({required super.apiClient, required super.tokenStorage});

  @override
  Future<Result<AdminUserPage>> getUsers({
    required String role,
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return executeRequest<AdminUserPage>(
      request: () => apiClient.dio.get(
        ApiEndpoints.adminUsers,
        queryParameters: {
          'role': role,
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
        return AdminUserPage(
          items: data
              .whereType<Map<String, dynamic>>()
              .map(AdminUser.fromJson)
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
  Future<Result<void>> setUserVerified({
    required int id,
    required bool isVerified,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.put(
        '${ApiEndpoints.adminUsers}/$id/verified',
        data: {'isVerified': isVerified},
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> createStaff({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.post(
        ApiEndpoints.adminStaffs,
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> updateStaff({
    required int id,
    required String name,
    String? phone,
    bool? isVerified,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.put(
        '${ApiEndpoints.adminStaffs}/$id',
        data: {
          'name': name,
          ...(phone == null ? <String, dynamic>{} : {'phone': phone}),
          ...(isVerified == null
              ? <String, dynamic>{}
              : {'isVerified': isVerified}),
        },
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> deleteStaff(int id) {
    return executeRequest<void>(
      request: () => apiClient.dio.delete('${ApiEndpoints.adminStaffs}/$id'),
      parser: (_) {},
    );
  }
}
