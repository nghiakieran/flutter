import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/core/blocs/base_bloc.dart';
import 'package:app_manager/features/admin/data/repositories/admin_dashboard_repository.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_dashboard_event.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_dashboard_state.dart';

class AdminDashboardBloc
    extends BaseBloc<AdminDashboardEvent, AdminDashboardState> {
  AdminDashboardBloc(this._repository) : super(const AdminDashboardState()) {
    on<LoadAdminDashboardRequested>(_onLoadDashboardRequested);
  }

  final IAdminDashboardRepository _repository;

  Future<void> _onLoadDashboardRequested(
    LoadAdminDashboardRequested event,
    Emitter<AdminDashboardState> emit,
  ) async {
    await executeWithErrorHandling(
      _repository.getDashboardSummary,
      onStart: () => emit(state.copyWith(isLoading: true, clearError: true)),
      onSuccess: (data) async {
        emit(state.copyWith(isLoading: false, summary: data, clearError: true));
      },
      onError: () async {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to load dashboard data.',
          ),
        );
      },
    );
  }
}
