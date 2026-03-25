import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_manager/core/services/connectivity_service.dart';

GoRouter createAppRouter({
  required GlobalKey<NavigatorState> rootNavigatorKey,
  required ConnectivityService connectivityService,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: connectivityService.statusNotifier,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink()),
    ],
  );
}
