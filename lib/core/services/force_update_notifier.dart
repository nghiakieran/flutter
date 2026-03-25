import 'package:flutter/foundation.dart';

class ForceUpdateState {
  const ForceUpdateState({required this.url});
  final String url;
}

class ForceUpdateNotifier {
  ForceUpdateNotifier._();

  static final ForceUpdateNotifier _instance = ForceUpdateNotifier._();
  factory ForceUpdateNotifier() => _instance;

  final ValueNotifier<ForceUpdateState?> notifier = ValueNotifier(null);

  ForceUpdateState? get state => notifier.value;

  void setRequired(String url) {
    if (url.isEmpty) return;
    notifier.value = ForceUpdateState(url: url);
  }

  void clear() {
    notifier.value = null;
  }
}
