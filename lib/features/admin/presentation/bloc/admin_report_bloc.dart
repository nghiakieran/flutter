import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/core/blocs/base_bloc.dart';
import 'package:app_manager/features/admin/data/repositories/admin_report_repository.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_report_event.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_report_state.dart';

class AdminReportBloc extends BaseBloc<AdminReportEvent, AdminReportState> {
  AdminReportBloc(this._repository) : super(const AdminReportState()) {
    on<LoadAdminReportRequested>(_onLoadReport);
  }

  final IAdminReportRepository _repository;

  Future<void> _onLoadReport(
    LoadAdminReportRequested event,
    Emitter<AdminReportState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.getSummary(
        period: event.period,
        from: event.from,
        to: event.to,
      ),
      onStart: () => emit(
        state.copyWith(isLoading: true, period: event.period, clearError: true),
      ),
      onSuccess: (data) async => emit(
        state.copyWith(isLoading: false, summary: data, clearError: true),
      ),
      onError: () async => emit(
        state.copyWith(isLoading: false, errorMessage: 'Load report failed'),
      ),
    );
  }
}
