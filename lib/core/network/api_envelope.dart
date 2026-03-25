class ApiEnvelope<T> {
  final int status;
  final String message;
  final T? data;

  const ApiEnvelope({required this.status, required this.message, this.data});

  bool get success => status >= 200 && status < 300;
}
