import 'package:flutter/material.dart';

import 'package:app_manager/core/navigation/app_router.dart';
import 'package:app_manager/core/services/connectivity_service.dart';
import 'package:go_router/go_router.dart';

class AppRouterConfig {
  AppRouterConfig({required ConnectivityService connectivityService}) {
    router = createAppRouter(
      rootNavigatorKey: rootNavigatorKey,
      connectivityService: connectivityService,
    );
  }

  late final GoRouter router;

  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  void dispose() {}
}
