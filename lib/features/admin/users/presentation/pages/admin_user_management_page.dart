import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/admin/users/data/models/admin_user_models.dart';
import 'package:app_manager/features/admin/users/presentation/bloc/admin_user_bloc.dart';
import 'package:app_manager/features/admin/users/presentation/bloc/admin_user_event.dart';
import 'package:app_manager/features/admin/users/presentation/bloc/admin_user_state.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_add_icon_button.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_page_app_bar.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_table_shell.dart';

class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminUserBloc>(
      create: (_) => getIt<AdminUserBloc>()
        ..add(const LoadAdminCustomersRequested())
        ..add(const LoadAdminStaffsRequested()),
      child: const _AdminUserManagementView(),
    );
  }
}

class _AdminUserManagementView extends StatelessWidget {
  const _AdminUserManagementView();

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String itemLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa $itemLabel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy', style: TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Xóa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _showStaffDialog(
    BuildContext context, {
    AdminUser? staff,
  }) async {
    final nameCtrl = TextEditingController(text: staff?.name ?? '');
    final emailCtrl = TextEditingController(text: staff?.email ?? '');
    final phoneCtrl = TextEditingController(text: staff?.phone ?? '');
    final passCtrl = TextEditingController();
    final isEdit = staff != null;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Row(
            children: [
              Icon(isEdit ? Icons.badge_outlined : Icons.person_add_alt_1_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(isEdit ? 'Sửa nhân viên' : 'Tạo nhân viên', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Tên nhân viên',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'Nhập họ tên...',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  if (!isEdit) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Email',
                        labelStyle: const TextStyle(fontSize: 14),
                        hintText: 'example@mail.com',
                        hintStyle: const TextStyle(fontSize: 14),
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passCtrl,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Mật khẩu',
                        labelStyle: const TextStyle(fontSize: 14),
                        hintText: '••••••••',
                        hintStyle: const TextStyle(fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      obscureText: true,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneCtrl,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Số điện thoại',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: '0xxx...',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (isEdit) {
                  context.read<AdminUserBloc>().add(
                    UpdateAdminStaffRequested(
                      id: staff.id,
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    ),
                  );
                } else {
                  context.read<AdminUserBloc>().add(
                    CreateAdminStaffRequested(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    ),
                  );
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: Text(isEdit ? 'Lưu' : 'Tạo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AdminPageAppBar(
          title: 'Quản lý người dùng',
          subtitle: 'Khách hàng và nhân sự nội bộ',
          bottom: TabBar(
            tabs: [
              Tab(text: 'Khách hàng'),
              Tab(text: 'Nhân viên'),
            ],
          ),
        ),
        body: BlocBuilder<AdminUserBloc, AdminUserState>(
          builder: (context, state) {
            return TabBarView(
              children: [
                AdminTableShell(
                  isLoading: state.isLoading,
                  enableSearch: true,
                  searchHint: 'Tìm khách hàng...',
                  onSearchChanged: (value) {
                    context.read<AdminUserBloc>().add(
                      LoadAdminCustomersRequested(
                        search: value,
                        page: 1,
                        limit: state.customerLimit,
                      ),
                    );
                  },
                  isRemotePagination: true,
                  currentPage: state.customerPage,
                  rowsPerPage: state.customerLimit,
                  totalPages: state.customerTotalPages,
                  onPageChanged: (page) {
                    context.read<AdminUserBloc>().add(
                      LoadAdminCustomersRequested(
                        search: state.customerSearch,
                        page: page,
                        limit: state.customerLimit,
                      ),
                    );
                  },
                  onRowsPerPageChanged: (limit) {
                    context.read<AdminUserBloc>().add(
                      LoadAdminCustomersRequested(
                        search: state.customerSearch,
                        page: 1,
                        limit: limit,
                      ),
                    );
                  },
                  columns: const [
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('Tên')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Kích hoạt')),
                    DataColumn(label: Text('Ngày tạo')),
                  ],
                  itemCount: state.customers.length,
                  totalItems: state.customerTotal,
                  onRefresh: () async {
                    context.read<AdminUserBloc>().add(
                      LoadAdminCustomersRequested(
                        search: state.customerSearch,
                        page: state.customerPage,
                        limit: state.customerLimit,
                      ),
                    );
                  },
                  emptyTitle: 'Chưa có khách hàng',
                  emptyMessage: 'Dữ liệu khách hàng sẽ hiển thị ở đây.',
                  rowBuilder: (index) {
                    final user = state.customers[index];
                    final stt =
                        ((state.customerPage - 1) * state.customerLimit) +
                        index +
                        1;
                    return DataRow(
                      cells: [
                        DataCell(Text('$stt')),
                        DataCell(Text(user.name)),
                        DataCell(Text(user.email)),
                        DataCell(
                          Switch(
                            value: user.isVerified,
                            onChanged: (v) {
                              context.read<AdminUserBloc>().add(
                                ToggleCustomerVerifiedRequested(
                                  userId: user.id,
                                  isVerified: v,
                                ),
                              );
                            },
                          ),
                        ),
                        DataCell(Text(_formatDate(user.createdAt))),
                      ],
                    );
                  },
                ),
                AdminTableShell(
                  isLoading: state.isLoading,
                  enableSearch: true,
                  searchHint: 'Tìm nhân viên...',
                  searchTrailing: AdminAddIconButton(
                    onPressed: () => _showStaffDialog(context),
                    tooltip: 'Thêm nhân viên',
                  ),
                  onSearchChanged: (value) {
                    context.read<AdminUserBloc>().add(
                      LoadAdminStaffsRequested(
                        search: value,
                        page: 1,
                        limit: state.staffLimit,
                      ),
                    );
                  },
                  isRemotePagination: true,
                  currentPage: state.staffPage,
                  rowsPerPage: state.staffLimit,
                  totalPages: state.staffTotalPages,
                  onPageChanged: (page) {
                    context.read<AdminUserBloc>().add(
                      LoadAdminStaffsRequested(
                        search: state.staffSearch,
                        page: page,
                        limit: state.staffLimit,
                      ),
                    );
                  },
                  onRowsPerPageChanged: (limit) {
                    context.read<AdminUserBloc>().add(
                      LoadAdminStaffsRequested(
                        search: state.staffSearch,
                        page: 1,
                        limit: limit,
                      ),
                    );
                  },
                  columns: const [
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('Tên')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Ngày tạo')),
                    DataColumn(label: Text('Thao tác')),
                  ],
                  itemCount: state.staffs.length,
                  totalItems: state.staffTotal,
                  onRefresh: () async {
                    context.read<AdminUserBloc>().add(
                      LoadAdminStaffsRequested(
                        search: state.staffSearch,
                        page: state.staffPage,
                        limit: state.staffLimit,
                      ),
                    );
                  },
                  emptyTitle: 'Chưa có nhân viên',
                  emptyMessage: 'Hãy thêm nhân viên để bắt đầu quản lý.',
                  rowBuilder: (index) {
                    final staff = state.staffs[index];
                    final stt =
                        ((state.staffPage - 1) * state.staffLimit) + index + 1;
                    return DataRow(
                      cells: [
                        DataCell(Text('$stt')),
                        DataCell(Text(staff.name)),
                        DataCell(Text(staff.email)),
                        DataCell(Text(_formatDate(staff.createdAt))),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _showStaffDialog(context, staff: staff),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final confirmed = await _confirmDelete(
                                    context,
                                    itemLabel: 'nhân viên "${staff.name}"',
                                  );
                                  if (!confirmed || !context.mounted) {
                                    return;
                                  }
                                  context.read<AdminUserBloc>().add(
                                    DeleteAdminStaffRequested(staff.id),
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFE57373),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
