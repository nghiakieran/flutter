typedef SystemErrorRetryCallback = Future<void> Function();

class SystemErrorRetryRegistry {
  SystemErrorRetryRegistry._();

  static final SystemErrorRetryRegistry instance = SystemErrorRetryRegistry._();

  SystemErrorRetryCallback? _lastRetry;

  void register(SystemErrorRetryCallback retry) {
    _lastRetry = retry;
  }

  Future<void> executeLast() async {
    final retry = _lastRetry;
    if (retry == null) return;
    await retry();
  }
}
