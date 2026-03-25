import 'package:flutter/material.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/core/services/snack_bar_service.dart';
import 'package:app_manager/theme/app_theme.dart';
import 'package:app_manager/core/navigation/app_router_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencyInjections();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouterConfig = getIt<AppRouterConfig>();
    return MaterialApp.router(
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      title: 'App Manager',
      scaffoldMessengerKey: SnackBarService.scaffoldKey,
      theme: AppThemeData.lightTheme,
      routerConfig: appRouterConfig.router,
    );
  }
}
