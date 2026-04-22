import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/core/blocs/base_bloc.dart';
import 'package:app_manager/features/admin/data/repositories/admin_user_repository.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_user_event.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_user_state.dart';

class AdminUserBloc extends BaseBloc<AdminUserEvent, AdminUserState> {
  AdminUserBloc(this._repository) : super(const AdminUserState()) {
    on<LoadAdminCustomersRequested>(_onLoadCustomers);
    on<LoadAdminStaffsRequested>(_onLoadStaffs);
    on<ToggleCustomerVerifiedRequested>(_onToggleCustomerVerified);
    on<CreateAdminStaffRequested>(_onCreateStaff);
    on<UpdateAdminStaffRequested>(_onUpdateStaff);
    on<DeleteAdminStaffRequested>(_onDeleteStaff);
  }

  final IAdminUserRepository _repository;

  Future<void> _onLoadCustomers(
    LoadAdminCustomersRequested event,
    Emitter<AdminUserState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.getUsers(
        role: 'USER',
        search: event.search ?? state.customerSearch,
        page: event.page ?? state.customerPage,
        limit: event.limit ?? state.customerLimit,
      ),
      onStart: () => emit(
        state.copyWith(
          isLoading: true,
          customerSearch: event.search ?? state.customerSearch,
          customerPage: event.page ?? state.customerPage,
          customerLimit: event.limit ?? state.customerLimit,
          clearError: true,
        ),
      ),
      onSuccess: (data) async => emit(
        state.copyWith(
          isLoading: false,
          customers: data.items,
          customerPage: data.page,
          customerLimit: data.limit,
          customerTotal: data.total,
          customerTotalPages: data.totalPages,
          clearError: true,
        ),
      ),
      onError: () async => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Tải danh sách khách hàng thất bại',
        ),
      ),
    );
  }

  Future<void> _onLoadStaffs(
    LoadAdminStaffsRequested event,
    Emitter<AdminUserState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.getUsers(
        role: 'ADMIN',
        search: event.search ?? state.staffSearch,
        page: event.page ?? state.staffPage,
        limit: event.limit ?? state.staffLimit,
      ),
      onStart: () => emit(
        state.copyWith(
          isLoading: true,
          staffSearch: event.search ?? state.staffSearch,
          staffPage: event.page ?? state.staffPage,
          staffLimit: event.limit ?? state.staffLimit,
          clearError: true,
        ),
      ),
      onSuccess: (data) async => emit(
        state.copyWith(
          isLoading: false,
          staffs: data.items,
          staffPage: data.page,
          staffLimit: data.limit,
          staffTotal: data.total,
          staffTotalPages: data.totalPages,
          clearError: true,
        ),
      ),
      onError: () async => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Tải danh sách nhân viên thất bại',
        ),
      ),
    );
  }

  Future<void> _onToggleCustomerVerified(
    ToggleCustomerVerifiedRequested event,
    Emitter<AdminUserState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.setUserVerified(
        id: event.userId,
        isVerified: event.isVerified,
      ),
      onSuccess: (_) async => add(
        LoadAdminCustomersRequested(
          search: state.customerSearch,
          page: state.customerPage,
          limit: state.customerLimit,
        ),
      ),
      onError: () async => emit(
        state.copyWith(errorMessage: 'Cập nhật trạng thái khách hàng thất bại'),
      ),
    );
  }

  Future<void> _onCreateStaff(
    CreateAdminStaffRequested event,
    Emitter<AdminUserState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.createStaff(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
      ),
      onSuccess: (_) async => add(
        LoadAdminStaffsRequested(
          search: state.staffSearch,
          page: 1,
          limit: state.staffLimit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Tạo nhân viên thất bại')),
    );
  }

  Future<void> _onUpdateStaff(
    UpdateAdminStaffRequested event,
    Emitter<AdminUserState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.updateStaff(
        id: event.id,
        name: event.name,
        phone: event.phone,
        isVerified: event.isVerified,
      ),
      onSuccess: (_) async => add(
        LoadAdminStaffsRequested(
          search: state.staffSearch,
          page: state.staffPage,
          limit: state.staffLimit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Cập nhật nhân viên thất bại')),
    );
  }

  Future<void> _onDeleteStaff(
    DeleteAdminStaffRequested event,
    Emitter<AdminUserState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.deleteStaff(event.id),
      onSuccess: (_) async => add(
        LoadAdminStaffsRequested(
          search: state.staffSearch,
          page: state.staffPage,
          limit: state.staffLimit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Xóa nhân viên thất bại')),
    );
  }
}
