import 'package:flutter/foundation.dart';

enum ConnectionStatus { unknown, online, offline }

/// Core-level connectivity abstraction.
///
/// This is a minimal stub to satisfy architecture compilation.
/// Replace the implementation with a real connectivity checker in your features layer later.
class ConnectivityService {
  final ValueNotifier<ConnectionStatus> statusNotifier = ValueNotifier(
    ConnectionStatus.unknown,
  );

  ConnectionStatus get currentStatus => statusNotifier.value;

  Future<void> checkConnection() async {
    // Minimal default behavior: assume online.
    // Swap this for a real implementation when you integrate features.
    statusNotifier.value = ConnectionStatus.online;
  }

  void dispose() {
    statusNotifier.dispose();
  }
}
