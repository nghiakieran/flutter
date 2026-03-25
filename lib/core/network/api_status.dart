enum HttpStatusCode {
  ok(200),
  created(201),
  noContent(204),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  conflict(409),
  unprocessable(422),
  tooManyRequests(429),
  serverError(500);

  const HttpStatusCode(this.code);
  final int code;

  static int normalize(dynamic statusCode) {
    if (statusCode is int) return statusCode;
    if (statusCode is String) return int.tryParse(statusCode) ?? 500;
    return 500;
  }

  static bool isSuccess(int code) => code >= 200 && code < 300;
  static bool isUnauthorized(int code) =>
      code == HttpStatusCode.unauthorized.code;
  static bool isClientError(int code) => code >= 400 && code < 500;
  static bool isServerError(int code) => code >= 500;
}
