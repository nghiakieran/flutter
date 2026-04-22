import 'package:get_it/get_it.dart';

import 'package:app_manager/core/network/api_client.dart';
import 'package:app_manager/core/services/connectivity_service.dart';
import 'package:app_manager/core/services/snack_bar_service.dart';
import 'package:app_manager/core/services/storage/i_token_storage.dart';
import 'package:app_manager/core/services/storage/shared_preferences_token_storage.dart';
import 'package:app_manager/core/services/force_update_notifier.dart';
import 'package:app_manager/core/services/system_error_retry_registry.dart';
import 'package:app_manager/core/services/system_error_notifier.dart';
import 'package:app_manager/core/navigation/app_router_config.dart';
import 'package:app_manager/features/admin/dashboard/data/repositories/admin_dashboard_repository.dart';
import 'package:app_manager/features/admin/orders/data/repositories/admin_order_repository.dart';
import 'package:app_manager/features/admin/products/data/repositories/admin_product_repository.dart';
import 'package:app_manager/features/admin/coupons/data/repositories/admin_coupon_repository.dart';
import 'package:app_manager/features/admin/reviews/data/repositories/admin_review_repository.dart';
import 'package:app_manager/features/admin/reports/data/repositories/admin_report_repository.dart';
import 'package:app_manager/features/admin/users/data/repositories/admin_user_repository.dart';
import 'package:app_manager/features/admin/dashboard/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:app_manager/features/admin/coupons/presentation/bloc/admin_coupon_bloc.dart';
import 'package:app_manager/features/admin/orders/presentation/bloc/admin_order_bloc.dart';
import 'package:app_manager/features/admin/products/presentation/bloc/admin_product_bloc.dart';
import 'package:app_manager/features/admin/reviews/presentation/bloc/admin_review_bloc.dart';
import 'package:app_manager/features/admin/reports/presentation/bloc/admin_report_bloc.dart';
import 'package:app_manager/features/admin/users/presentation/bloc/admin_user_bloc.dart';
import 'package:app_manager/features/auth/data/repositories/auth_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencyInjections() async {
  // Core singletons
  if (!getIt.isRegistered<ITokenStorage>()) {
    getIt.registerLazySingleton<ITokenStorage>(
      () => SharedPreferencesTokenStorage(),
    );
  }

  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(
      () => ApiClient(tokenStorage: getIt<ITokenStorage>()),
    );
  }

  if (!getIt.isRegistered<ConnectivityService>()) {
    getIt.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(),
    );
  }

  if (!getIt.isRegistered<SystemErrorRetryRegistry>()) {
    getIt.registerLazySingleton<SystemErrorRetryRegistry>(
      () => SystemErrorRetryRegistry.instance,
    );
  }

  if (!getIt.isRegistered<SystemErrorNotifier>()) {
    getIt.registerLazySingleton<SystemErrorNotifier>(
      () => SystemErrorNotifier(),
    );
  }

  if (!getIt.isRegistered<ForceUpdateNotifier>()) {
    getIt.registerLazySingleton<ForceUpdateNotifier>(
      () => ForceUpdateNotifier(),
    );
  }

  if (!getIt.isRegistered<AppRouterConfig>()) {
    getIt.registerLazySingleton<AppRouterConfig>(
      () => AppRouterConfig(connectivityService: getIt<ConnectivityService>()),
    );
  }

  if (!getIt.isRegistered<IAuthRepository>()) {
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepository(getIt<ApiClient>()),
    );
  }

  if (!getIt.isRegistered<IAdminDashboardRepository>()) {
    getIt.registerLazySingleton<IAdminDashboardRepository>(
      () => AdminDashboardRepository(
        apiClient: getIt<ApiClient>(),
        tokenStorage: getIt<ITokenStorage>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdminDashboardBloc>()) {
    getIt.registerFactory<AdminDashboardBloc>(
      () => AdminDashboardBloc(getIt<IAdminDashboardRepository>()),
    );
  }

  if (!getIt.isRegistered<IAdminOrderRepository>()) {
    getIt.registerLazySingleton<IAdminOrderRepository>(
      () => AdminOrderRepository(
        apiClient: getIt<ApiClient>(),
        tokenStorage: getIt<ITokenStorage>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdminOrderBloc>()) {
    getIt.registerFactory<AdminOrderBloc>(
      () => AdminOrderBloc(getIt<IAdminOrderRepository>()),
    );
  }

  if (!getIt.isRegistered<IAdminProductRepository>()) {
    getIt.registerLazySingleton<IAdminProductRepository>(
      () => AdminProductRepository(
        apiClient: getIt<ApiClient>(),
        tokenStorage: getIt<ITokenStorage>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdminProductBloc>()) {
    getIt.registerFactory<AdminProductBloc>(
      () => AdminProductBloc(getIt<IAdminProductRepository>()),
    );
  }

  if (!getIt.isRegistered<IAdminUserRepository>()) {
    getIt.registerLazySingleton<IAdminUserRepository>(
      () => AdminUserRepository(
        apiClient: getIt<ApiClient>(),
        tokenStorage: getIt<ITokenStorage>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdminUserBloc>()) {
    getIt.registerFactory<AdminUserBloc>(
      () => AdminUserBloc(getIt<IAdminUserRepository>()),
    );
  }

  if (!getIt.isRegistered<IAdminCouponRepository>()) {
    getIt.registerLazySingleton<IAdminCouponRepository>(
      () => AdminCouponRepository(
        apiClient: getIt<ApiClient>(),
        tokenStorage: getIt<ITokenStorage>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdminCouponBloc>()) {
    getIt.registerFactory<AdminCouponBloc>(
      () => AdminCouponBloc(getIt<IAdminCouponRepository>()),
    );
  }

  if (!getIt.isRegistered<IAdminReviewRepository>()) {
    getIt.registerLazySingleton<IAdminReviewRepository>(
      () => AdminReviewRepository(
        apiClient: getIt<ApiClient>(),
        tokenStorage: getIt<ITokenStorage>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdminReviewBloc>()) {
    getIt.registerFactory<AdminReviewBloc>(
      () => AdminReviewBloc(getIt<IAdminReviewRepository>()),
    );
  }

  if (!getIt.isRegistered<IAdminReportRepository>()) {
    getIt.registerLazySingleton<IAdminReportRepository>(
      () => AdminReportRepository(
        apiClient: getIt<ApiClient>(),
        tokenStorage: getIt<ITokenStorage>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdminReportBloc>()) {
    getIt.registerFactory<AdminReportBloc>(
      () => AdminReportBloc(getIt<IAdminReportRepository>()),
    );
  }

  await getIt<ApiClient>().syncTokenFromStorage();

  SnackBarService.scaffoldKey;
}
