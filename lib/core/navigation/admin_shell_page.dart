import 'package:flutter/material.dart';

import 'package:app_manager/features/admin/shared/presentation/widgets/admin_bottom_navigation.dart';

class AdminShellPage extends StatelessWidget {
  const AdminShellPage({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  final Widget child;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AdminBottomNavigation(currentRoute: currentRoute),
    );
  }
}
