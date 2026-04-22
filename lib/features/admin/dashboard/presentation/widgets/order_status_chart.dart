import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/features/admin/dashboard/data/models/admin_dashboard_models.dart';

class OrderStatusChart extends StatelessWidget {
  const OrderStatusChart({super.key, required this.items});

  final List<DashboardOrderStatusMetric> items;

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

  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(0, (sum, item) => sum + item.count);

    if (items.isEmpty || total == 0) {
      return Text(
        'Chưa có thống kê đơn hàng.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      children: items.map((item) {
        final ratio = item.count / total;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _statusLabel(item.status),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${item.count}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: ratio.clamp(0, 1),
                  backgroundColor: AppColors.neutral100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
