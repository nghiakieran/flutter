import 'package:get_it/get_it.dart';

import 'package:app_manager/core/network/api_client.dart';
import 'package:app_manager/core/services/connectivity_service.dart';
import 'package:app_manager/core/services/snack_bar_service.dart';
import 'package:app_manager/core/services/storage/in_memory_token_storage.dart';
import 'package:app_manager/core/services/storage/i_token_storage.dart';
import 'package:app_manager/core/services/force_update_notifier.dart';
import 'package:app_manager/core/services/system_error_retry_registry.dart';
import 'package:app_manager/core/services/system_error_notifier.dart';
import 'package:app_manager/core/navigation/app_router_config.dart';
import 'package:app_manager/features/auth/data/repositories/auth_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencyInjections() async {
  // Core singletons
  if (!getIt.isRegistered<ITokenStorage>()) {
    getIt.registerLazySingleton<ITokenStorage>(() => InMemoryTokenStorage());
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

  await getIt<ApiClient>().syncTokenFromStorage();

  SnackBarService.scaffoldKey;
}
