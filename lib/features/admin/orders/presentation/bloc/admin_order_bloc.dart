import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/core/blocs/base_bloc.dart';
import 'package:app_manager/features/admin/orders/data/repositories/admin_order_repository.dart';
import 'package:app_manager/features/admin/orders/presentation/bloc/admin_order_event.dart';
import 'package:app_manager/features/admin/orders/presentation/bloc/admin_order_state.dart';

class AdminOrderBloc extends BaseBloc<AdminOrderEvent, AdminOrderState> {
  AdminOrderBloc(this._repository) : super(const AdminOrderState()) {
    on<LoadAdminOrdersRequested>(_onLoadOrdersRequested);
    on<UpdateAdminOrderStatusRequested>(_onUpdateOrderStatusRequested);
  }

  final IAdminOrderRepository _repository;

  Future<void> _onLoadOrdersRequested(
    LoadAdminOrdersRequested event,
    Emitter<AdminOrderState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.getOrders(
        status: event.status,
        search: event.search,
        page: event.page ?? state.page,
        limit: event.limit ?? state.limit,
      ),
      onStart: () => emit(
        state.copyWith(
          isLoading: true,
          statusFilter: event.status ?? state.statusFilter,
          search: event.search ?? state.search,
          page: event.page ?? state.page,
          limit: event.limit ?? state.limit,
          clearError: true,
        ),
      ),
      onSuccess: (data) async {
        emit(
          state.copyWith(
            isLoading: false,
            items: data.items,
            page: data.page,
            limit: data.limit,
            total: data.total,
            totalPages: data.totalPages,
            clearError: true,
          ),
        );
      },
      onError: () async {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to load orders',
          ),
        );
      },
    );
  }

  Future<void> _onUpdateOrderStatusRequested(
    UpdateAdminOrderStatusRequested event,
    Emitter<AdminOrderState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.updateOrderStatus(
        orderId: event.orderId,
        status: event.status,
      ),
      onSuccess: (_) async {
        add(
          LoadAdminOrdersRequested(
            status: state.statusFilter,
            search: state.search,
            page: state.page,
            limit: state.limit,
          ),
        );
      },
      onError: () async {
        emit(state.copyWith(errorMessage: 'Failed to update status'));
      },
    );
  }
}
