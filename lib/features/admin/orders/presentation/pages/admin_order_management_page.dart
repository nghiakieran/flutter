import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/admin/orders/presentation/bloc/admin_order_bloc.dart';
import 'package:app_manager/features/admin/orders/presentation/bloc/admin_order_event.dart';
import 'package:app_manager/features/admin/orders/presentation/bloc/admin_order_state.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_page_app_bar.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_table_shell.dart';
import 'package:app_manager/shared/widgets/error-empty/error_state_widget.dart';

class AdminOrderManagementPage extends StatelessWidget {
  const AdminOrderManagementPage({super.key});

  static String _statusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'SHIPPING':
        return 'Đang giao';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'CANCEL_REQUESTED':
        return 'Yêu cầu hủy';
      default:
        return status;
    }
  }

  static const List<String> _statuses = <String>[
    '',
    'PENDING',
    'CONFIRMED',
    'SHIPPING',
    'COMPLETED',
    'CANCELLED',
    'CANCEL_REQUESTED',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminOrderBloc>(
      create: (_) =>
          getIt<AdminOrderBloc>()..add(const LoadAdminOrdersRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AdminPageAppBar(
          title: 'Quản lý đơn hàng',
          subtitle: 'Theo dõi và xử lý trạng thái giao dịch',
        ),
        body: BlocBuilder<AdminOrderBloc, AdminOrderState>(
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _statuses.contains(state.statusFilter)
                        ? state.statusFilter
                        : '',
                    decoration: const InputDecoration(
                      labelText: 'Lọc theo trạng thái',
                    ),
                    items: _statuses
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status.isEmpty ? 'Tất cả' : _statusLabel(status),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      context.read<AdminOrderBloc>().add(
                        LoadAdminOrdersRequested(
                          status: value ?? '',
                          search: state.search,
                          page: 1,
                          limit: state.limit,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ErrorStateWidget(
                      title: 'Lỗi',
                      message: state.errorMessage!,
                      onRetry: () {
                        context.read<AdminOrderBloc>().add(
                          const LoadAdminOrdersRequested(),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: AdminTableShell(
                    isLoading: state.isLoading,
                    enableSearch: true,
                    searchHint: 'Tìm theo mã đơn...',
                    onSearchChanged: (value) {
                      context.read<AdminOrderBloc>().add(
                        LoadAdminOrdersRequested(
                          status: state.statusFilter,
                          search: value,
                          page: 1,
                          limit: state.limit,
                        ),
                      );
                    },
                    isRemotePagination: true,
                    currentPage: state.page,
                    rowsPerPage: state.limit,
                    totalPages: state.totalPages,
                    onPageChanged: (page) {
                      context.read<AdminOrderBloc>().add(
                        LoadAdminOrdersRequested(
                          status: state.statusFilter,
                          search: state.search,
                          page: page,
                          limit: state.limit,
                        ),
                      );
                    },
                    onRowsPerPageChanged: (limit) {
                      context.read<AdminOrderBloc>().add(
                        LoadAdminOrdersRequested(
                          status: state.statusFilter,
                          search: state.search,
                          page: 1,
                          limit: limit,
                        ),
                      );
                    },
                    columns: const [
                      DataColumn(label: Text('Mã đơn')),
                      DataColumn(label: Text('Người nhận')),
                      DataColumn(label: Text('Tổng tiền')),
                      DataColumn(label: Text('Trạng thái')),
                      DataColumn(label: Text('Thao tác')),
                    ],
                    itemCount: state.items.length,
                    totalItems: state.total,
                    onRefresh: () async {
                      context.read<AdminOrderBloc>().add(
                        LoadAdminOrdersRequested(
                          status: state.statusFilter,
                          search: state.search,
                          page: state.page,
                          limit: state.limit,
                        ),
                      );
                    },
                    emptyTitle: 'Chưa có đơn hàng',
                    emptyMessage: 'Không có dữ liệu phù hợp bộ lọc hiện tại.',
                    rowBuilder: (index) {
                      final item = state.items[index];
                      return DataRow(
                        cells: [
                          DataCell(Text(item.orderCode)),
                          DataCell(Text(item.receiverName)),
                          DataCell(Text(item.total.toStringAsFixed(0))),
                          DataCell(Text(_statusLabel(item.status))),
                          DataCell(
                            Wrap(
                              spacing: 4,
                              children:
                                  [
                                        'CONFIRMED',
                                        'SHIPPING',
                                        'COMPLETED',
                                        'CANCELLED',
                                      ]
                                      .map(
                                        (nextStatus) => OutlinedButton(
                                          onPressed: () {
                                            context.read<AdminOrderBloc>().add(
                                              UpdateAdminOrderStatusRequested(
                                                orderId: item.id,
                                                status: nextStatus,
                                              ),
                                            );
                                          },
                                          child: Text(_statusLabel(nextStatus)),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
