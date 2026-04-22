import 'package:flutter/material.dart';

import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/core/network/api_client.dart';
import 'package:app_manager/core/navigation/router_constants.dart';
import 'package:app_manager/core/navigation/router_helper.dart';
import 'package:app_manager/core/services/storage/i_token_storage.dart';
import 'package:app_manager/features/admin/data/repositories/admin_review_repository.dart';

class AdminBottomNavigation extends StatefulWidget {
  const AdminBottomNavigation({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  State<AdminBottomNavigation> createState() => _AdminBottomNavigationState();
}

class _AdminBottomNavigationState extends State<AdminBottomNavigation> {
  int? _pendingReviewCount;
  static const String _logoutAction = '__logout__';
  static const Color _menuSurface = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadPendingReviewCount();
  }

  Future<void> _loadPendingReviewCount() async {
    final result = await getIt<IAdminReviewRepository>().getReviews(
      isVisible: false,
      page: 1,
      limit: 1,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingReviewCount = result.data?.total ?? 0;
    });
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi hệ thống?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    return result == true;
  }

  int _resolveCurrentIndex() {
    if (widget.currentRoute == AppRoutes.adminDashboard) {
      return 0;
    }
    if (widget.currentRoute == AppRoutes.adminProducts ||
        widget.currentRoute == AppRoutes.adminReviews) {
      return 1;
    }
    if (widget.currentRoute == AppRoutes.adminOrders ||
        widget.currentRoute == AppRoutes.adminCoupons ||
        widget.currentRoute == AppRoutes.adminReports) {
      return 2;
    }
    if (widget.currentRoute == AppRoutes.adminUsers) {
      return 3;
    }
    if (widget.currentRoute == AppRoutes.adminProfile) {
      return 4;
    }
    return 0;
  }

  Widget _buildNavIcon({
    required int itemIndex,
    required IconData icon,
    bool withBadge = false,
  }) {
    final isSelected = _resolveCurrentIndex() == itemIndex;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x142563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon),
              if (withBadge && (_pendingReviewCount ?? 0) > 0)
                Positioned(
                  right: -8,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      _pendingReviewCount! > 99
                          ? '99+'
                          : '$_pendingReviewCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showQuickMenu({
    required String title,
    required List<({String value, IconData icon, String label, bool danger})>
    actions,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - value)),
              child: child,
            ),
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: _menuSurface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4DCE5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  ...actions.asMap().entries.map((entry) {
                    final i = entry.key;
                    final action = entry.value;
                    final isLast = i == actions.length - 1;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(ctx).pop(action.value),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: action.danger
                                    ? const Color(0xFFFFEBEE)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                action.icon,
                                size: 18,
                                color: action.danger
                                    ? Colors.redAccent
                                    : const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                action.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: action.danger
                                      ? Colors.redAccent
                                      : const Color(0xFF111827),
                                ),
                              ),
                            ),
                            Icon(
                              isLast && action.danger
                                  ? Icons.warning_amber_rounded
                                  : Icons.chevron_right_rounded,
                              color: action.danger
                                  ? Colors.redAccent
                                  : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _resolveCurrentIndex(),
      onTap: (index) async {
        if (index == 0) {
          if (widget.currentRoute != AppRoutes.adminDashboard) {
            goRoute(context, AppRoutes.adminDashboard);
          }
          return;
        }

        if (index == 3) {
          if (widget.currentRoute != AppRoutes.adminUsers) {
            goRoute(context, AppRoutes.adminUsers);
          }
          return;
        }

        final selected = index == 1
            ? await _showQuickMenu(
                title: 'Nhóm sản phẩm',
                actions: const [
                  (
                    value: AppRoutes.adminProducts,
                    icon: Icons.inventory_2_outlined,
                    label: 'Sản phẩm',
                    danger: false,
                  ),
                  (
                    value: '${AppRoutes.adminProducts}?tab=brand',
                    icon: Icons.branding_watermark_outlined,
                    label: 'Thương hiệu',
                    danger: false,
                  ),
                  (
                    value: AppRoutes.adminReviews,
                    icon: Icons.rate_review_outlined,
                    label: 'Đánh giá',
                    danger: false,
                  ),
                ],
              )
            : index == 2
            ? await _showQuickMenu(
                title: 'Nhóm giao dịch',
                actions: const [
                  (
                    value: AppRoutes.adminOrders,
                    icon: Icons.receipt_long_outlined,
                    label: 'Đơn hàng',
                    danger: false,
                  ),
                  (
                    value: AppRoutes.adminCoupons,
                    icon: Icons.local_offer_outlined,
                    label: 'Khuyến mãi',
                    danger: false,
                  ),
                  (
                    value: AppRoutes.adminReports,
                    icon: Icons.insert_chart_outlined,
                    label: 'Báo cáo',
                    danger: false,
                  ),
                ],
              )
            : await _showQuickMenu(
                title: 'Cá nhân',
                actions: const [
                  (
                    value: AppRoutes.adminProfile,
                    icon: Icons.person_outline,
                    label: 'Hồ sơ quản trị',
                    danger: false,
                  ),
                  (
                    value: _logoutAction,
                    icon: Icons.logout,
                    label: 'Đăng xuất',
                    danger: true,
                  ),
                ],
              );

        if (!context.mounted) {
          return;
        }
        if (selected == _logoutAction) {
          final confirmed = await _confirmLogout(context);
          if (!confirmed) {
            return;
          }
          await getIt<ITokenStorage>().clearTokens();
          getIt<ApiClient>().clearToken();
          if (!context.mounted) {
            return;
          }
          goRoute(context, AppRoutes.login);
          return;
        }

        if (selected != null &&
            selected != widget.currentRoute &&
            selected != '${widget.currentRoute}?tab=brand') {
          goRoute(context, selected);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: _buildNavIcon(itemIndex: 0, icon: Icons.dashboard_outlined),
          label: 'Tổng quan',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(itemIndex: 1, icon: Icons.inventory_2_outlined),
          label: 'Sản phẩm',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(itemIndex: 2, icon: Icons.payments_outlined),
          label: 'Giao dịch',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(itemIndex: 3, icon: Icons.people_outline),
          label: 'Người dùng',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(
            itemIndex: 4,
            icon: Icons.person_outline,
            withBadge: true,
          ),
          label: 'Cá nhân',
        ),
      ],
    );
  }
}
