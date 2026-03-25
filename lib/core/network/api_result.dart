class Result<T> {
  const Result._({
    this.data,
    this.error,
    this.message,
    this.statusCode,
    this.originalMessage,
  });

  factory Result.success(T data, {int? statusCode, String? message}) =>
      Result._(data: data, statusCode: statusCode, message: message);

  factory Result.failure(
    String error, {
    int? statusCode,
    String? message,
    String? originalMessage,
  }) => Result._(
    error: error,
    statusCode: statusCode,
    message: message,
    originalMessage: originalMessage,
  );

  final T? data;
  final String? error;
  final String? message;
  final int? statusCode;
  final String? originalMessage;

  bool get isSuccess =>
      error == null &&
      (statusCode == null || statusCode! >= 200 && statusCode! < 300);

  bool get isUnauthorized => statusCode == 401;

  static Result<R> fromEnvelope<R>(
    dynamic raw, {
    required R Function(dynamic data) parse,
    String? customErrorMessage,
  }) {
    if (raw is Map<String, dynamic>) {
      final sc = raw['statusCode'] ?? raw['status'];
      final msg = raw['message'];
      final dat = raw['data'] ?? raw; // fallback if no `data` field
      final code = sc is int
          ? sc
          : (sc is String ? int.tryParse(sc) : null) ?? 200;

      if (code >= 200 && code < 300) {
        try {
          final parsed = parse(dat);
          return Result.success(
            parsed,
            statusCode: code,
            message: msg?.toString(),
          );
        } catch (e) {
          return Result.failure(
            customErrorMessage ?? 'Data parsing error',
            statusCode: code,
            message: msg?.toString(),
            originalMessage: e.toString(),
          );
        }
      }

      return Result.failure(
        (customErrorMessage ?? msg?.toString() ?? 'Request failed'),
        statusCode: code,
        message: msg?.toString(),
        originalMessage: msg?.toString(),
      );
    }

    try {
      final parsed = parse(raw);
      return Result.success(parsed, statusCode: 200);
    } catch (e) {
      return Result.failure(
        customErrorMessage ?? 'Invalid response format',
        statusCode: 500,
        originalMessage: e.toString(),
      );
    }
  }
}
