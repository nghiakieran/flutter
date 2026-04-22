import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/core/blocs/base_bloc.dart';
import 'package:app_manager/features/admin/data/repositories/admin_coupon_repository.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_coupon_event.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_coupon_state.dart';

class AdminCouponBloc extends BaseBloc<AdminCouponEvent, AdminCouponState> {
  AdminCouponBloc(this._repository) : super(const AdminCouponState()) {
    on<LoadAdminCouponsRequested>(_onLoadCoupons);
    on<CreateAdminCouponRequested>(_onCreateCoupon);
    on<UpdateAdminCouponRequested>(_onUpdateCoupon);
    on<DeleteAdminCouponRequested>(_onDeleteCoupon);
  }

  final IAdminCouponRepository _repository;

  Future<void> _onLoadCoupons(
    LoadAdminCouponsRequested event,
    Emitter<AdminCouponState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.getCoupons(
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
          coupons: data.items,
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
          errorMessage: 'Tải danh sách mã giảm giá thất bại',
        ),
      ),
    );
  }

  Future<void> _onCreateCoupon(
    CreateAdminCouponRequested event,
    Emitter<AdminCouponState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.createCoupon(
        code: event.code,
        type: event.type,
        value: event.value,
        minOrderValue: event.minOrderValue,
        maxDiscountValue: event.maxDiscountValue,
        startDateIso: event.startDateIso,
        endDateIso: event.endDateIso,
        usageLimit: event.usageLimit,
        isActive: event.isActive,
      ),
      onSuccess: (_) async => add(
        LoadAdminCouponsRequested(
          search: state.search,
          page: 1,
          limit: state.limit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Tạo mã giảm giá thất bại')),
    );
  }

  Future<void> _onUpdateCoupon(
    UpdateAdminCouponRequested event,
    Emitter<AdminCouponState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.updateCoupon(
        id: event.id,
        code: event.code,
        type: event.type,
        value: event.value,
        minOrderValue: event.minOrderValue,
        maxDiscountValue: event.maxDiscountValue,
        startDateIso: event.startDateIso,
        endDateIso: event.endDateIso,
        usageLimit: event.usageLimit,
        isActive: event.isActive,
      ),
      onSuccess: (_) async => add(
        LoadAdminCouponsRequested(
          search: state.search,
          page: state.page,
          limit: state.limit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Cập nhật mã giảm giá thất bại')),
    );
  }

  Future<void> _onDeleteCoupon(
    DeleteAdminCouponRequested event,
    Emitter<AdminCouponState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.deleteCoupon(event.id),
      onSuccess: (_) async => add(
        LoadAdminCouponsRequested(
          search: state.search,
          page: state.page,
          limit: state.limit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Xóa mã giảm giá thất bại')),
    );
  }
}
