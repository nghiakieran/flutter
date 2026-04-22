import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/admin/data/models/admin_coupon_models.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_coupon_bloc.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_coupon_event.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_coupon_state.dart';
import 'package:app_manager/features/admin/presentation/widgets/admin_add_icon_button.dart';
import 'package:app_manager/features/admin/presentation/widgets/admin_page_app_bar.dart';
import 'package:app_manager/features/admin/presentation/widgets/admin_table_shell.dart';

class AdminCouponManagementPage extends StatelessWidget {
  const AdminCouponManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminCouponBloc>(
      create: (_) =>
          getIt<AdminCouponBloc>()..add(const LoadAdminCouponsRequested()),
      child: const _AdminCouponManagementView(),
    );
  }
}

class _AdminCouponManagementView extends StatelessWidget {
  const _AdminCouponManagementView();

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
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _showCouponDialog(
    BuildContext context, {
    AdminCoupon? coupon,
  }) async {
    final codeCtrl = TextEditingController(text: coupon?.code ?? '');
    final typeCtrl = ValueNotifier<String>(coupon?.type ?? 'PERCENT');
    final valueCtrl = TextEditingController(
      text: coupon == null ? '' : '${coupon.value}',
    );
    final minCtrl = TextEditingController(
      text: coupon == null ? '' : '${coupon.minOrderValue}',
    );
    final maxCtrl = TextEditingController(
      text: coupon?.maxDiscountValue == null
          ? ''
          : '${coupon!.maxDiscountValue}',
    );
    final usageCtrl = TextEditingController(
      text: coupon == null ? '100' : '${coupon.usageLimit}',
    );
    final startCtrl = TextEditingController(
      text: (coupon?.startDate ?? DateTime.now()).toIso8601String(),
    );
    final endCtrl = TextEditingController(
      text: (coupon?.endDate ?? DateTime.now().add(const Duration(days: 30)))
          .toIso8601String(),
    );
    final active = ValueNotifier<bool>(coupon?.isActive ?? true);
    final isEdit = coupon != null;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Sửa mã giảm giá' : 'Tạo mã giảm giá'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã'),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: typeCtrl,
                builder: (_, value, _) => DropdownButtonFormField<String>(
                  initialValue: value,
                  items: const [
                    DropdownMenuItem(
                      value: 'PERCENT',
                      child: Text('Phần trăm'),
                    ),
                    DropdownMenuItem(value: 'AMOUNT', child: Text('Số tiền')),
                  ],
                  onChanged: (v) {
                    if (v != null) typeCtrl.value = v;
                  },
                  decoration: const InputDecoration(labelText: 'Loại'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá trị'),
              ),
              TextField(
                controller: minCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá trị đơn tối thiểu',
                ),
              ),
              TextField(
                controller: maxCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giảm tối đa (không bắt buộc)',
                ),
              ),
              TextField(
                controller: usageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giới hạn sử dụng',
                ),
              ),
              TextField(
                controller: startCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ngày bắt đầu (ISO)',
                ),
              ),
              TextField(
                controller: endCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ngày kết thúc (ISO)',
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: active,
                builder: (_, v, _) => SwitchListTile(
                  value: v,
                  onChanged: (nv) => active.value = nv,
                  title: const Text('Kích hoạt'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final payload = (
                code: codeCtrl.text.trim(),
                type: typeCtrl.value,
                value: double.tryParse(valueCtrl.text.trim()) ?? 0,
                minOrderValue: double.tryParse(minCtrl.text.trim()) ?? 0,
                maxDiscountValue: maxCtrl.text.trim().isEmpty
                    ? null
                    : double.tryParse(maxCtrl.text.trim()),
                startDateIso: startCtrl.text.trim(),
                endDateIso: endCtrl.text.trim(),
                usageLimit: int.tryParse(usageCtrl.text.trim()) ?? 0,
                isActive: active.value,
              );

              if (isEdit) {
                context.read<AdminCouponBloc>().add(
                  UpdateAdminCouponRequested(
                    id: coupon.id,
                    code: payload.code,
                    type: payload.type,
                    value: payload.value,
                    minOrderValue: payload.minOrderValue,
                    maxDiscountValue: payload.maxDiscountValue,
                    startDateIso: payload.startDateIso,
                    endDateIso: payload.endDateIso,
                    usageLimit: payload.usageLimit,
                    isActive: payload.isActive,
                  ),
                );
              } else {
                context.read<AdminCouponBloc>().add(
                  CreateAdminCouponRequested(
                    code: payload.code,
                    type: payload.type,
                    value: payload.value,
                    minOrderValue: payload.minOrderValue,
                    maxDiscountValue: payload.maxDiscountValue,
                    startDateIso: payload.startDateIso,
                    endDateIso: payload.endDateIso,
                    usageLimit: payload.usageLimit,
                    isActive: payload.isActive,
                  ),
                );
              }
              Navigator.of(ctx).pop();
            },
            child: Text(isEdit ? 'Lưu' : 'Tạo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AdminPageAppBar(
        title: 'Quản lý mã giảm giá',
        subtitle: 'Thiết lập chương trình khuyến mãi',
      ),
      body: BlocBuilder<AdminCouponBloc, AdminCouponState>(
        builder: (context, state) {
          return AdminTableShell(
            isLoading: state.isLoading,
            enableSearch: true,
            searchHint: 'Tìm theo mã giảm giá...',
            searchTrailing: AdminAddIconButton(
              onPressed: () => _showCouponDialog(context),
              tooltip: 'Thêm mã giảm giá',
            ),
            onSearchChanged: (value) {
              context.read<AdminCouponBloc>().add(
                LoadAdminCouponsRequested(
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
              context.read<AdminCouponBloc>().add(
                LoadAdminCouponsRequested(
                  search: state.search,
                  page: page,
                  limit: state.limit,
                ),
              );
            },
            onRowsPerPageChanged: (limit) {
              context.read<AdminCouponBloc>().add(
                LoadAdminCouponsRequested(
                  search: state.search,
                  page: 1,
                  limit: limit,
                ),
              );
            },
            columns: const [
              DataColumn(label: Text('STT')),
              DataColumn(label: Text('Mã')),
              DataColumn(label: Text('Loại')),
              DataColumn(label: Text('Giá trị')),
              DataColumn(label: Text('Giới hạn')),
              DataColumn(label: Text('Ngày tạo')),
              DataColumn(label: Text('Thao tác')),
            ],
            itemCount: state.coupons.length,
            totalItems: state.total,
            onRefresh: () async {
              context.read<AdminCouponBloc>().add(
                LoadAdminCouponsRequested(
                  search: state.search,
                  page: state.page,
                  limit: state.limit,
                ),
              );
            },
            emptyTitle: 'Chưa có mã giảm giá',
            emptyMessage:
                'Hãy thêm mã giảm giá để hệ thống áp dụng khuyến mãi.',
            rowBuilder: (index) {
              final c = state.coupons[index];
              final stt = ((state.page - 1) * state.limit) + index + 1;
              return DataRow(
                cells: [
                  DataCell(Text('$stt')),
                  DataCell(Text(c.code)),
                  DataCell(Text(c.type)),
                  DataCell(Text(c.value.toStringAsFixed(0))),
                  DataCell(Text('${c.usageLimit}')),
                  DataCell(Text(_formatDate(c.createdAt))),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              _showCouponDialog(context, coupon: c),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () async {
                            final confirmed = await _confirmDelete(
                              context,
                              itemLabel: 'mã giảm giá "${c.code}"',
                            );
                            if (!confirmed || !context.mounted) {
                              return;
                            }
                            context.read<AdminCouponBloc>().add(
                              DeleteAdminCouponRequested(c.id),
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
          );
        },
      ),
    );
  }
}
