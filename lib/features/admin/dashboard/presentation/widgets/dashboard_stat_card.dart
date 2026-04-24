import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/features/admin/dashboard/data/models/admin_dashboard_models.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({super.key, required this.metric});

  final DashboardMetricCard metric;

  String _localizedLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'revenue (day)':
        return 'Doanh thu (ngày)';
      case 'revenue (month)':
        return 'Doanh thu (tháng)';
      case 'revenue (year)':
        return 'Doanh thu (năm)';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = metric.delta >= 0;
    final deltaPrefix = isPositive ? '+' : '';
    final formatter = NumberFormat.decimalPattern('vi_VN');
    final isRevenue = metric.label.toLowerCase().contains('revenue');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedLabel(metric.label),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isRevenue
                  ? '${formatter.format(metric.value)} đ'
                  : formatter.format(metric.value),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$deltaPrefix${metric.delta.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
