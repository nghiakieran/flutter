import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/admin/coupons/data/models/admin_coupon_models.dart';
import 'package:app_manager/features/admin/coupons/presentation/bloc/admin_coupon_bloc.dart';
import 'package:app_manager/features/admin/coupons/presentation/bloc/admin_coupon_event.dart';
import 'package:app_manager/features/admin/coupons/presentation/bloc/admin_coupon_state.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_add_icon_button.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_page_app_bar.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_table_shell.dart';

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
            child: const Text('Hủy', style: TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
    final valueCtrl = TextEditingController(text: coupon == null ? '' : '${coupon.value}');
    final minCtrl = TextEditingController(text: coupon == null ? '' : '${coupon.minOrderValue}');
    final maxCtrl = TextEditingController(text: coupon?.maxDiscountValue == null ? '' : '${coupon!.maxDiscountValue}');
    final usageCtrl = TextEditingController(text: coupon == null ? '100' : '${coupon.usageLimit}');
    final startCtrl = TextEditingController(text: (coupon?.startDate ?? DateTime.now()).toIso8601String());
    final endCtrl = TextEditingController(text: (coupon?.endDate ?? DateTime.now().add(const Duration(days: 30))).toIso8601String());
    final active = ValueNotifier<bool>(coupon?.isActive ?? true);
    final isEdit = coupon != null;

    Future<void> pickDate(TextEditingController ctrl, String label) async {
      final current = DateTime.tryParse(ctrl.text) ?? DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: current,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        helpText: 'Chọn $label',
      );
      if (picked != null) {
        ctrl.text = picked.toIso8601String();
      }
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Row(
            children: [
              Icon(isEdit ? Icons.edit_calendar_outlined : Icons.add_card_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(isEdit ? 'Sửa mã giảm giá' : 'Tạo mã giảm giá', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    controller: codeCtrl,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Mã giảm giá',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'VD: SALE50',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.local_offer_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: typeCtrl,
                          builder: (_, value, __) => DropdownButtonFormField<String>(
                            value: value,
                            isDense: true,
                            style: const TextStyle(fontSize: 15, color: Colors.black),
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Loại',
                              labelStyle: const TextStyle(fontSize: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'PERCENT', child: Text('Phần trăm')),
                              DropdownMenuItem(value: 'AMOUNT', child: Text('Số tiền')),
                            ],
                            onChanged: (v) {
                              if (v != null) typeCtrl.value = v;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: valueCtrl,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Giá trị',
                            labelStyle: const TextStyle(fontSize: 14),
                            hintText: '0',
                            hintStyle: const TextStyle(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtrl,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Đơn tối thiểu',
                            labelStyle: const TextStyle(fontSize: 14),
                            hintText: '0',
                            hintStyle: const TextStyle(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxCtrl,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Giảm tối đa',
                            labelStyle: const TextStyle(fontSize: 14),
                            hintText: 'Không giới hạn',
                            hintStyle: const TextStyle(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usageCtrl,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Giới hạn sử dụng',
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.people_outline, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await pickDate(startCtrl, 'ngày bắt đầu');
                            setLocalState(() {});
                          },
                          child: IgnorePointer(
                            child: TextField(
                              controller: TextEditingController(text: _formatDate(DateTime.tryParse(startCtrl.text))),
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                isDense: true,
                                labelText: 'Ngày bắt đầu',
                                labelStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await pickDate(endCtrl, 'ngày kết thúc');
                            setLocalState(() {});
                          },
                          child: IgnorePointer(
                            child: TextField(
                              controller: TextEditingController(text: _formatDate(DateTime.tryParse(endCtrl.text))),
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                isDense: true,
                                labelText: 'Ngày kết thúc',
                                labelStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.event_outlined, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<bool>(
                    valueListenable: active,
                    builder: (_, v, __) => SwitchListTile(
                      value: v,
                      onChanged: (nv) => active.value = nv,
                      title: const Text('Kích hoạt mã', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    ),
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
                final payload = (
                  code: codeCtrl.text.trim().toUpperCase(),
                  type: typeCtrl.value,
                  value: double.tryParse(valueCtrl.text.trim()) ?? 0,
                  minOrderValue: double.tryParse(minCtrl.text.trim()) ?? 0,
                  maxDiscountValue: maxCtrl.text.trim().isEmpty ? null : double.tryParse(maxCtrl.text.trim()),
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
