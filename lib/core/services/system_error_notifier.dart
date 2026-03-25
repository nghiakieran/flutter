import 'dart:async';

/// Lightweight notifier used by the app shell to react to system errors.
class SystemErrorNotifier {
  SystemErrorNotifier._();

  static final SystemErrorNotifier _instance = SystemErrorNotifier._();
  factory SystemErrorNotifier() => _instance;

  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() {
    if (_controller.isClosed) return;
    _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}
