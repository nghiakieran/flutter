import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_dashboard_event.dart';
import 'package:app_manager/features/admin/presentation/bloc/admin_dashboard_state.dart';
import 'package:app_manager/features/admin/presentation/widgets/admin_page_app_bar.dart';
import 'package:app_manager/features/admin/presentation/widgets/dashboard_stat_card.dart';
import 'package:app_manager/features/admin/presentation/widgets/order_status_chart.dart';
import 'package:app_manager/shared/widgets/error-empty/error_state_widget.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminDashboardBloc>(
      create: (_) =>
          getIt<AdminDashboardBloc>()..add(const LoadAdminDashboardRequested()),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AdminPageAppBar(
        title: 'Bảng điều khiển',
        subtitle: 'Tổng quan chỉ số vận hành hôm nay',
      ),
      body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          if (state.isLoading && state.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.summary == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ErrorStateWidget(
                title: 'Lỗi bảng điều khiển',
                message: state.errorMessage!,
                onRetry: () {
                  context.read<AdminDashboardBloc>().add(
                    const LoadAdminDashboardRequested(),
                  );
                },
              ),
            );
          }

          final summary = state.summary;
          if (summary == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminDashboardBloc>().add(
                const LoadAdminDashboardRequested(),
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Thống kê nhanh',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    DashboardStatCard(metric: summary.todayRevenue),
                    DashboardStatCard(metric: summary.monthRevenue),
                    DashboardStatCard(metric: summary.yearRevenue),
                    Container(
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
                            'Người dùng',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${summary.totalUsers}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
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
                        'Đơn hàng theo trạng thái',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      OrderStatusChart(items: summary.orderByStatus),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sử dụng thanh điều hướng bên dưới để quản lý các phân hệ.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
