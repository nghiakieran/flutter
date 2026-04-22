import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';

class AdminPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminPageAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.bottom,
  });

  final String title;
  final String subtitle;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(76 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 76,
      centerTitle: true,
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3F8FC), Color(0xFFE8F1F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      bottom: bottom,
    );
  }
}
