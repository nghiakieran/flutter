import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/admin/data/repositories/admin_report_repository.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_report_bloc.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_report_event.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_report_state.dart';
import 'package:app_manager/features/admin/presentation/widgets/admin_page_app_bar.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  static const List<String> _periods = ['day', 'month', 'year'];
  static const Map<String, String> _periodLabels = {
    'day': 'Ngày',
    'month': 'Tháng',
    'year': 'Năm',
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminReportBloc>(
      create: (_) =>
          getIt<AdminReportBloc>()
            ..add(const LoadAdminReportRequested(period: 'month')),
      child: const _AdminReportsView(),
    );
  }
}

class _AdminReportsView extends StatelessWidget {
  const _AdminReportsView();

  String _statusLabel(String status) {
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

  Future<void> _previewExport(
    BuildContext context, {
    required String format,
    required String period,
  }) async {
    final result = await getIt<IAdminReportRepository>().exportContent(
      format: format,
      period: period,
    );
    final content = result.data ?? result.error ?? 'Xuất báo cáo thất bại';
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          format == 'excel' ? 'Xem trước Excel (CSV)' : 'Xem trước Word',
        ),
        content: SingleChildScrollView(child: SelectableText(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
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
        title: 'Báo cáo',
        subtitle: 'Phân tích doanh thu và hiệu suất bán hàng',
      ),
      body: BlocBuilder<AdminReportBloc, AdminReportState>(
        builder: (context, state) {
          final summary = state.summary;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: state.period,
                decoration: const InputDecoration(labelText: 'Kỳ báo cáo'),
                items: AdminReportsPage._periods
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          AdminReportsPage._periodLabels[p] ?? p.toUpperCase(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  context.read<AdminReportBloc>().add(
                    LoadAdminReportRequested(period: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (state.isLoading) const LinearProgressIndicator(),
              if (summary != null) ...[
                _MetricCard(
                  title: 'Doanh thu',
                  value: summary.totals.revenue.toStringAsFixed(0),
                ),
                _MetricCard(
                  title: 'Đơn hàng',
                  value: '${summary.totals.orders}',
                ),
                _MetricCard(
                  title: 'Người dùng',
                  value: '${summary.totals.users}',
                ),
                _MetricCard(
                  title: 'Giá trị đơn TB',
                  value: summary.totals.aov.toStringAsFixed(2),
                ),
                const SizedBox(height: 12),
                Text(
                  'Trạng thái đơn hàng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ...summary.statuses.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BarMetricRow(
                      label: _statusLabel(s.status),
                      value: s.count.toDouble(),
                      max: summary.statuses.fold<double>(
                        1,
                        (m, e) => e.count > m ? e.count.toDouble() : m,
                      ),
                      trailing: '${s.count}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sản phẩm bán chạy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ...summary.topProducts.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BarMetricRow(
                      label: p.name,
                      value: p.soldQty.toDouble(),
                      max: summary.topProducts.fold<double>(
                        1,
                        (m, e) => e.soldQty > m ? e.soldQty.toDouble() : m,
                      ),
                      trailing: 'Đã bán: ${p.soldQty}',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => _previewExport(
                      context,
                      format: 'excel',
                      period: state.period,
                    ),
                    child: const Text('Xuất Excel'),
                  ),
                  ElevatedButton(
                    onPressed: () => _previewExport(
                      context,
                      format: 'word',
                      period: state.period,
                    ),
                    child: const Text('Xuất Word'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BarMetricRow extends StatelessWidget {
  const _BarMetricRow({
    required this.label,
    required this.value,
    required this.max,
    required this.trailing,
  });

  final String label;
  final double value;
  final double max;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
            Text(trailing),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.neutral100,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
