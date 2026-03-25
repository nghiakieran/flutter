import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void goRoute(BuildContext context, String route, {Object? extra}) {
  if (context.mounted) {
    context.go(route, extra: extra);
  }
}

Future<T?> pushRoute<T extends Object?>(
  BuildContext context,
  String route, {
  Object? extra,
}) async {
  if (context.mounted) {
    return context.push<T>(route, extra: extra);
  }
  return null;
}

void goBack(BuildContext context) {
  if (context.mounted && context.canPop()) {
    context.pop();
  }
}

void pushReplacementRoute(BuildContext context, String route, {Object? extra}) {
  if (context.mounted) {
    context.pushReplacement(route, extra: extra);
  }
}
