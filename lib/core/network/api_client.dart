import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:app_manager/core/environment/app_environment.dart';
import 'package:app_manager/core/services/storage/i_token_storage.dart';

class ApiClient {
  ApiClient({required ITokenStorage tokenStorage})
    : _tokenStorage = tokenStorage,
      _dio = Dio(
        BaseOptions(
          baseUrl: AppEnvironment.apiBaseUrl,
          connectTimeout: const Duration(seconds: 100),
          receiveTimeout: const Duration(seconds: 100),
          headers: const {'Content-Type': 'application/json'},
          followRedirects: true,
          // Don't treat 4xx as DioException, we'll parse via BaseService/Result.
          validateStatus: (status) => status != null && status < 500,
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_isAdminRoute(options.path)) {
            debugPrint(
              '[ADMIN API][REQUEST] ${options.method} ${options.baseUrl}${options.path}',
            );
            if (options.queryParameters.isNotEmpty) {
              debugPrint('[ADMIN API][QUERY] ${options.queryParameters}');
            }
            if (options.data != null) {
              debugPrint('[ADMIN API][PAYLOAD] ${options.data}');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          final options = response.requestOptions;
          if (_isAdminRoute(options.path)) {
            debugPrint(
              '[ADMIN API][RESPONSE] ${response.statusCode} ${options.method} ${options.baseUrl}${options.path}',
            );
            debugPrint('[ADMIN API][BODY] ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          final options = error.requestOptions;
          if (_isAdminRoute(options.path)) {
            debugPrint(
              '[ADMIN API][ERROR] ${error.response?.statusCode ?? 'NO_STATUS'} ${options.method} ${options.baseUrl}${options.path}',
            );
            if (error.response?.data != null) {
              debugPrint('[ADMIN API][ERROR_BODY] ${error.response?.data}');
            } else {
              debugPrint('[ADMIN API][ERROR_MSG] ${error.message}');
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final ITokenStorage _tokenStorage;

  String? _token;

  Dio get dio => _dio;
  String? get token => _token;

  Future<void> syncTokenFromStorage() async {
    final access = await _tokenStorage.getAccessToken();
    if (access != null && access.isNotEmpty) {
      setToken(access);
    }
  }

  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  bool _isAdminRoute(String path) {
    return path.contains('/admin/');
  }
}
