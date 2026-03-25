import 'dart:async';

import 'package:dio/dio.dart';

import 'package:app_manager/core/network/api_client.dart';
import 'package:app_manager/core/network/api_endpoints.dart';
import 'package:app_manager/core/network/api_envelope.dart';
import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/network/api_status.dart';
import 'package:app_manager/core/services/storage/i_token_storage.dart';
import 'package:app_manager/core/services/system_error_retry_registry.dart';
import 'package:app_manager/core/services/system_error_notifier.dart';

abstract class BaseService {
  BaseService({
    required ApiClient apiClient,
    required ITokenStorage tokenStorage,
    SystemErrorNotifier? systemErrorNotifier,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage,
       _systemErrorNotifier = systemErrorNotifier ?? SystemErrorNotifier();

  final ApiClient _apiClient;
  final ITokenStorage _tokenStorage;
  final SystemErrorNotifier _systemErrorNotifier;

  ApiClient get apiClient => _apiClient;

  Result<T> _buildResultFromResponse<T>(
    Response<dynamic> res,
    T Function(dynamic data) parser, {
    String? customErrorMessage,
  }) {
    final http = res.statusCode ?? 500;
    final body = res.data;

    if (body is Map<String, dynamic> &&
        (body.containsKey('statusCode') || body.containsKey('status'))) {
      return Result.fromEnvelope<T>(
        body,
        parse: parser,
        customErrorMessage: customErrorMessage,
      );
    }

    if (HttpStatusCode.isSuccess(http)) {
      final envelope = ApiEnvelope<dynamic>(
        status: http,
        message: '',
        data: body,
      );

      return Result.fromEnvelope<T>(
        {
          'status': envelope.status,
          'message': envelope.message,
          'data': envelope.data,
        },
        parse: parser,
        customErrorMessage: customErrorMessage,
      );
    }

    return Result.failure(
      customErrorMessage ?? 'Request failed',
      statusCode: http,
      originalMessage: body?.toString(),
    );
  }

  static Future<bool>? _refreshFuture;

  Future<bool> _tryRefreshToken() async {
    if (_refreshFuture != null) {
      return await _refreshFuture!;
    }

    _refreshFuture = _doRefreshToken();

    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _doRefreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final res = await _apiClient.dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final http = res.statusCode ?? 500;
      if (!HttpStatusCode.isSuccess(http)) return false;

      final body = res.data;
      dynamic tokenData = body;

      if (body is Map && body['data'] is Map) {
        tokenData = body['data'];
      }

      if (tokenData is Map) {
        final newAccess = tokenData['accessToken']?.toString();
        final newRefresh = tokenData['refreshToken']?.toString();

        if (newAccess != null &&
            newAccess.isNotEmpty &&
            newRefresh != null &&
            newRefresh.isNotEmpty) {
          await _tokenStorage.storeTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          _apiClient.setToken(newAccess);
          return true;
        }
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Result<T>> executeRequest<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(dynamic data) parser,
    String? customErrorMessage,
  }) async {
    try {
      final res = await request();
      final http = res.statusCode ?? 500;

      if (HttpStatusCode.isUnauthorized(http)) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          final retryRes = await request();
          return _buildResultFromResponse<T>(
            retryRes,
            parser,
            customErrorMessage: customErrorMessage,
          );
        }
      }

      if (HttpStatusCode.isServerError(http)) {
        SystemErrorRetryRegistry.instance.register(
          () async => executeRequest<T>(
            request: request,
            parser: parser,
            customErrorMessage: customErrorMessage,
          ),
        );
        _systemErrorNotifier.notify();
      }

      return _buildResultFromResponse<T>(
        res,
        parser,
        customErrorMessage: customErrorMessage,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 500;

      final body = e.response?.data;
      if (body is Map<String, dynamic>) {
        return Result.fromEnvelope<T>(
          body,
          parse: parser,
          customErrorMessage: customErrorMessage,
        );
      }

      if (HttpStatusCode.isServerError(code)) {
        SystemErrorRetryRegistry.instance.register(
          () async => executeRequest<T>(
            request: request,
            parser: parser,
            customErrorMessage: customErrorMessage,
          ),
        );
        _systemErrorNotifier.notify();
      }

      return Result.failure(
        customErrorMessage ?? 'Network error',
        statusCode: code,
        originalMessage: e.message,
      );
    } catch (e) {
      return Result.failure(
        customErrorMessage ?? 'Unexpected error',
        statusCode: 500,
        originalMessage: e.toString(),
      );
    }
  }
}
