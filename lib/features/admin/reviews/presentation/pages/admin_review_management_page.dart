import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/admin/reviews/data/models/admin_review_models.dart';
import 'package:app_manager/features/admin/reviews/presentation/bloc/admin_review_bloc.dart';
import 'package:app_manager/features/admin/reviews/presentation/bloc/admin_review_event.dart';
import 'package:app_manager/features/admin/reviews/presentation/bloc/admin_review_state.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_page_app_bar.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_table_shell.dart';

class AdminReviewManagementPage extends StatelessWidget {
  const AdminReviewManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminReviewBloc>(
      create: (_) =>
          getIt<AdminReviewBloc>()..add(const LoadAdminReviewsRequested()),
      child: const _AdminReviewManagementView(),
    );
  }
}

class _AdminReviewManagementView extends StatelessWidget {
  const _AdminReviewManagementView();

  Future<void> _showReplyDialog(
    BuildContext context,
    AdminReview review,
  ) async {
    final replyCtrl = TextEditingController(text: review.adminReply ?? '');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Phản hồi đánh giá'),
        content: TextField(
          controller: replyCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Nội dung phản hồi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminReviewBloc>().add(
                ReplyAdminReviewRequested(
                  id: review.id,
                  adminReply: replyCtrl.text.trim(),
                ),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Lưu'),
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
        title: 'Quản lý đánh giá',
        subtitle: 'Duyệt hiển thị và phản hồi người dùng',
      ),
      body: BlocBuilder<AdminReviewBloc, AdminReviewState>(
        builder: (context, state) {
          return AdminTableShell(
            isLoading: state.isLoading,
            enableSearch: true,
            searchHint: 'Tìm nội dung đánh giá...',
            onSearchChanged: (value) {
              context.read<AdminReviewBloc>().add(
                LoadAdminReviewsRequested(
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
              context.read<AdminReviewBloc>().add(
                LoadAdminReviewsRequested(
                  search: state.search,
                  page: page,
                  limit: state.limit,
                ),
              );
            },
            onRowsPerPageChanged: (limit) {
              context.read<AdminReviewBloc>().add(
                LoadAdminReviewsRequested(
                  search: state.search,
                  page: 1,
                  limit: limit,
                ),
              );
            },
            columns: const [
              DataColumn(label: Text('Người dùng')),
              DataColumn(label: Text('Sản phẩm')),
              DataColumn(label: Text('Điểm')),
              DataColumn(label: Text('Hiển thị')),
              DataColumn(label: Text('Phản hồi')),
            ],
            itemCount: state.reviews.length,
            totalItems: state.total,
            onRefresh: () async {
              context.read<AdminReviewBloc>().add(
                LoadAdminReviewsRequested(
                  search: state.search,
                  page: state.page,
                  limit: state.limit,
                ),
              );
            },
            emptyTitle: 'Chưa có đánh giá',
            emptyMessage: 'Đánh giá từ khách hàng sẽ hiển thị ở đây.',
            rowBuilder: (index) {
              final review = state.reviews[index];
              return DataRow(
                cells: [
                  DataCell(Text(review.userName ?? 'Người dùng')),
                  DataCell(Text(review.productName ?? 'Sản phẩm')),
                  DataCell(Text('⭐ ${review.rating}')),
                  DataCell(
                    Switch(
                      value: review.isVisible,
                      onChanged: (v) {
                        context.read<AdminReviewBloc>().add(
                          UpdateAdminReviewVisibilityRequested(
                            id: review.id,
                            isVisible: v,
                          ),
                        );
                      },
                    ),
                  ),
                  DataCell(
                    IconButton(
                      onPressed: () => _showReplyDialog(context, review),
                      icon: const Icon(Icons.reply_outlined),
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
