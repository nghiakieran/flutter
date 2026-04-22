import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/core/blocs/base_bloc.dart';
import 'package:app_manager/features/admin/data/repositories/admin_review_repository.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_review_event.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_review_state.dart';

class AdminReviewBloc extends BaseBloc<AdminReviewEvent, AdminReviewState> {
  AdminReviewBloc(this._repository) : super(const AdminReviewState()) {
    on<LoadAdminReviewsRequested>(_onLoad);
    on<UpdateAdminReviewVisibilityRequested>(_onToggleVisibility);
    on<ReplyAdminReviewRequested>(_onReply);
  }

  final IAdminReviewRepository _repository;

  Future<void> _onLoad(
    LoadAdminReviewsRequested event,
    Emitter<AdminReviewState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.getReviews(
        search: event.search ?? state.search,
        page: event.page ?? state.page,
        limit: event.limit ?? state.limit,
      ),
      onStart: () => emit(
        state.copyWith(
          isLoading: true,
          search: event.search ?? state.search,
          page: event.page ?? state.page,
          limit: event.limit ?? state.limit,
          clearError: true,
        ),
      ),
      onSuccess: (data) async => emit(
        state.copyWith(
          isLoading: false,
          reviews: data.items,
          page: data.page,
          limit: data.limit,
          total: data.total,
          totalPages: data.totalPages,
          clearError: true,
        ),
      ),
      onError: () async => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Tải danh sách đánh giá thất bại',
        ),
      ),
    );
  }

  Future<void> _onToggleVisibility(
    UpdateAdminReviewVisibilityRequested event,
    Emitter<AdminReviewState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.updateVisibility(
        id: event.id,
        isVisible: event.isVisible,
      ),
      onSuccess: (_) async => add(
        LoadAdminReviewsRequested(
          search: state.search,
          page: state.page,
          limit: state.limit,
        ),
      ),
      onError: () async => emit(
        state.copyWith(errorMessage: 'Cập nhật hiển thị đánh giá thất bại'),
      ),
    );
  }

  Future<void> _onReply(
    ReplyAdminReviewRequested event,
    Emitter<AdminReviewState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.replyReview(id: event.id, adminReply: event.adminReply),
      onSuccess: (_) async => add(
        LoadAdminReviewsRequested(
          search: state.search,
          page: state.page,
          limit: state.limit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Phản hồi đánh giá thất bại')),
    );
  }
}
