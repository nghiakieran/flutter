import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/services/base_service.dart';
import 'package:app_manager/features/admin/products/data/models/admin_product_models.dart';

abstract class IAdminProductRepository {
  Future<Result<AdminProductPage>> getProducts({
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Result<void>> createProduct({
    required String name,
    required double price,
    required int stock,
    int? categoryId,
    String? image,
  });
  Future<Result<void>> updateProduct({
    required int id,
    required String name,
    required double price,
    required int stock,
    String? image,
  });
  Future<Result<void>> deleteProduct(int id);

  Future<Result<AdminBrandPage>> getBrands({
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Result<void>> createBrand(String name, {String? image});
  Future<Result<void>> updateBrand({
    required int id,
    required String name,
    String? image,
  });
  Future<Result<void>> deleteBrand(int id);
}

class AdminProductRepository extends BaseService
    implements IAdminProductRepository {
  AdminProductRepository({
    required super.apiClient,
    required super.tokenStorage,
  });

  @override
  Future<Result<AdminProductPage>> getProducts({
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return executeRequest<AdminProductPage>(
      request: () => apiClient.dio.get(
        ApiEndpoints.adminProducts,
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
        return AdminProductPage(
          items: data
              .whereType<Map<String, dynamic>>()
              .map(AdminProduct.fromJson)
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
  Future<Result<void>> createProduct({
    required String name,
    required double price,
    required int stock,
    int? categoryId,
    String? image,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.post(
        ApiEndpoints.adminProducts,
        data: {
          'name': name,
          'price': price,
          'stock': stock,
          ...(image == null || image.isEmpty
              ? <String, dynamic>{}
              : {'image': image}),
          ...(categoryId == null
              ? <String, dynamic>{}
              : {'categoryId': categoryId}),
        },
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> updateProduct({
    required int id,
    required String name,
    required double price,
    required int stock,
    String? image,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.put(
        '${ApiEndpoints.adminProducts}/$id',
        data: {
          'name': name,
          'price': price,
          'stock': stock,
          ...(image == null || image.isEmpty
              ? <String, dynamic>{}
              : {'image': image}),
        },
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> deleteProduct(int id) {
    return executeRequest<void>(
      request: () => apiClient.dio.delete('${ApiEndpoints.adminProducts}/$id'),
      parser: (_) {},
    );
  }

  @override
  Future<Result<AdminBrandPage>> getBrands({
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return executeRequest<AdminBrandPage>(
      request: () => apiClient.dio.get(
        ApiEndpoints.adminBrands,
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
        return AdminBrandPage(
          items: data
              .whereType<Map<String, dynamic>>()
              .map(AdminBrand.fromJson)
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
  Future<Result<void>> createBrand(String name, {String? image}) {
    return executeRequest<void>(
      request: () => apiClient.dio.post(
        ApiEndpoints.adminBrands,
        data: {
          'name': name,
          ...(image == null || image.isEmpty
              ? <String, dynamic>{}
              : {'image': image}),
        },
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> updateBrand({
    required int id,
    required String name,
    String? image,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.put(
        '${ApiEndpoints.adminBrands}/$id',
        data: {
          'name': name,
          ...(image == null || image.isEmpty
              ? <String, dynamic>{}
              : {'image': image}),
        },
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> deleteBrand(int id) {
    return executeRequest<void>(
      request: () => apiClient.dio.delete('${ApiEndpoints.adminBrands}/$id'),
      parser: (_) {},
    );
  }
}
