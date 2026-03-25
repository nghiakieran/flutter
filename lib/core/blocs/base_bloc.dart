import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/core/network/api_result.dart';
import 'package:app_manager/core/services/snack_bar_service.dart';

abstract class BaseBloc<E, S> extends Bloc<E, S> {
  BaseBloc(super.initialState, {this.onUnauthorized});

  final FutureOr<void> Function(BuildContext context)? onUnauthorized;

  Future<void> executeWithErrorHandling<T>(
    Future<Result<T>> Function() operation, {
    required Future<void> Function(T data) onSuccess,
    required Future<void> Function() onError,
    void Function()? onStart,
    void Function()? onFinally,
    BuildContext? context,
    bool showSnackBarOnError = false,
    String? customErrorMessage,
  }) async {
    try {
      onStart?.call();
      final result = await operation();

      final isValidSuccess =
          result.isSuccess && (result.data != null || T.toString() == 'void');

      if (isValidSuccess) {
        await onSuccess(result.data as T);
        return;
      }

      if (result.isUnauthorized) {
        if (onUnauthorized != null && context != null && context.mounted) {
          await onUnauthorized!(context);
        } else if (showSnackBarOnError && context != null && context.mounted) {
          SnackBarService.showSnackBar(
            content: customErrorMessage ?? result.error ?? 'Unauthorized',
            status: StatusSnackBar.error,
          );
        }
        return;
      }

      if (showSnackBarOnError && context != null && context.mounted) {
        SnackBarService.showSnackBar(
          content:
              customErrorMessage ?? result.error ?? result.message ?? 'Error',
          status: StatusSnackBar.error,
        );
      }

      await onError();
    } catch (e) {
      if (showSnackBarOnError && context != null && context.mounted) {
        SnackBarService.showSnackBar(
          content: customErrorMessage ?? 'Unexpected error',
          status: StatusSnackBar.error,
        );
      }
      await onError();
    } finally {
      onFinally?.call();
    }
  }
}
