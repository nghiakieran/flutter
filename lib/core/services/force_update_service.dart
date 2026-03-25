import 'package:flutter/foundation.dart';

/// Core-level force update checker.
///
/// This is intentionally generic so it doesn't depend on any `features/*` models.
class ForceUpdateConfig {
  const ForceUpdateConfig({
    required this.forceUpdate,
    required this.androidVersion,
    required this.iosVersion,
    required this.androidLink,
    required this.iosLink,
  });

  final bool forceUpdate;
  final String androidVersion;
  final String iosVersion;
  final String androidLink;
  final String iosLink;
}

class ForceUpdateService {
  const ForceUpdateService._();

  /// Returns true if a forced update is required based on version comparison.
  static bool isForceUpdateRequired({
    required ForceUpdateConfig config,
    required String currentVersion,
  }) {
    if (!config.forceUpdate) return false;

    final serverVersion = defaultTargetPlatform == TargetPlatform.iOS
        ? config.iosVersion
        : config.androidVersion;

    return _compareVersions(currentVersion, serverVersion) < 0;
  }

  static String getUpdateLink(ForceUpdateConfig config) {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? config.iosLink
        : config.androidLink;
  }

  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = parts1.length > parts2.length
        ? parts1.length
        : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }

    return 0;
  }
}
