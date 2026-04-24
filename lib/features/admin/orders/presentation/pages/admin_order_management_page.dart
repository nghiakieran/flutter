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
                      DataColumn(label: Text('Mã giảm giá')),
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
                      final displayedTotal = item.finalTotal > 0
                          ? item.finalTotal
                          : item.total;
                      final couponLabel = item.couponCode?.trim().isNotEmpty == true
                          ? item.couponCode!
                          : (item.discount > 0
                              ? '-${item.discount.toStringAsFixed(0)}đ'
                              : '---');

                      // Logic for valid next statuses
                      List<String> nextStatuses = [];
                      if (item.status == 'PENDING') {
                        nextStatuses = ['CONFIRMED', 'CANCELLED'];
                      } else if (item.status == 'CONFIRMED') {
                        nextStatuses = ['SHIPPING', 'CANCELLED'];
                      } else if (item.status == 'SHIPPING') {
                        nextStatuses = ['COMPLETED'];
                      } else if (item.status == 'CANCEL_REQUESTED') {
                        nextStatuses = ['CANCELLED', 'CONFIRMED'];
                      }

                      return DataRow(
                        cells: [
                          DataCell(Text(item.orderCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                          DataCell(Text(item.receiverName, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          DataCell(
                            Text(
                              couponLabel,
                              style: TextStyle(
                                color: item.couponCode?.trim().isNotEmpty == true
                                    ? Colors.deepPurple
                                    : (item.discount > 0
                                        ? Colors.orange
                                        : Colors.grey),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(Text('${displayedTotal.toStringAsFixed(0)}đ', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _getStatusColor(item.status).withOpacity(0.5)),
                              ),
                              child: Text(
                                _statusLabel(item.status),
                                style: TextStyle(
                                  color: _getStatusColor(item.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            nextStatuses.isEmpty 
                            ? const Text('---', style: TextStyle(color: Colors.grey))
                            : PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: AppColors.primary),
                                tooltip: 'Thay đổi trạng thái',
                                onSelected: (nextStatus) {
                                  context.read<AdminOrderBloc>().add(
                                    UpdateAdminOrderStatusRequested(
                                      orderId: item.id,
                                      status: nextStatus,
                                    ),
                                  );
                                },
                                itemBuilder: (context) => nextStatuses.map((status) => PopupMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Icon(_getStatusIcon(status), size: 18, color: _getStatusColor(status)),
                                      const SizedBox(width: 10),
                                      Text('Chuyển thành: ${_statusLabel(status)}'),
                                    ],
                                  ),
                                )).toList(),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING': return Colors.orange;
      case 'CONFIRMED': return Colors.blue;
      case 'SHIPPING': return Colors.purple;
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'CANCEL_REQUESTED': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'CONFIRMED': return Icons.check_circle_outline;
      case 'SHIPPING': return Icons.local_shipping_outlined;
      case 'COMPLETED': return Icons.done_all;
      case 'CANCELLED': return Icons.cancel_outlined;
      default: return Icons.edit_notifications_outlined;
    }
  }
}
