import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/services/base_service.dart';
import 'package:app_manager/features/admin/reviews/data/models/admin_review_models.dart';

abstract class IAdminReviewRepository {
  Future<Result<AdminReviewPage>> getReviews({
    String? search,
    bool? isVisible,
    int page = 1,
    int limit = 10,
  });
  Future<Result<void>> updateVisibility({
    required int id,
    required bool isVisible,
  });
  Future<Result<void>> replyReview({
    required int id,
    required String adminReply,
  });
}

class AdminReviewRepository extends BaseService
    implements IAdminReviewRepository {
  AdminReviewRepository({
    required super.apiClient,
    required super.tokenStorage,
  });

  @override
  Future<Result<AdminReviewPage>> getReviews({
    String? search,
    bool? isVisible,
    int page = 1,
    int limit = 10,
  }) {
    return executeRequest<AdminReviewPage>(
      request: () => apiClient.dio.get(
        ApiEndpoints.adminReviews,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          ...(isVisible == null
              ? <String, dynamic>{}
              : {'isVisible': isVisible}),
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
        return AdminReviewPage(
          items: data
              .whereType<Map<String, dynamic>>()
              .map(AdminReview.fromJson)
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
  Future<Result<void>> updateVisibility({
    required int id,
    required bool isVisible,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.put(
        '${ApiEndpoints.adminReviews}/$id/visibility',
        data: {'isVisible': isVisible},
      ),
      parser: (_) {},
    );
  }

  @override
  Future<Result<void>> replyReview({
    required int id,
    required String adminReply,
  }) {
    return executeRequest<void>(
      request: () => apiClient.dio.put(
        '${ApiEndpoints.adminReviews}/$id/reply',
        data: {'adminReply': adminReply},
      ),
      parser: (_) {},
    );
  }
}
