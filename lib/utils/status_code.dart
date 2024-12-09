enum HTTPStatusCode {
  // Informational responses (100–199)
  continue_(100, "Continue"),
  switchingProtocols(101, "Switching Protocols"),
  processing(102, "Processing"),

  // Successful responses (200–299)
  ok(200, "OK"),
  created(201, "Created"),
  accepted(202, "Accepted"),
  nonAuthoritativeInformation(203, "Non-Authoritative Information"),
  noContent(204, "No Content"),
  resetContent(205, "Reset Content"),
  partialContent(206, "Partial Content"),

  // Redirection messages (300–399)
  multipleChoices(300, "Multiple Choices"),
  movedPermanently(301, "Moved Permanently"),
  found(302, "Found"),
  notModified(304, "Not Modified"),
  temporaryRedirect(307, "Temporary Redirect"),
  permanentRedirect(308, "Permanent Redirect"),

  // Client error responses (400–499)
  badRequest(400, "Bad Request"),
  unauthorized(401, "Unauthorized"),
  forbidden(403, "Forbidden"),
  notFound(404, "Not Found"),
  methodNotAllowed(405, "Method Not Allowed"),
  requestTimeout(408, "Request Timeout"),
  conflict(409, "Conflict"),
  gone(410, "Gone"),

  // Server error responses (500–599)
  internalServerError(500, "Internal Server Error"),
  notImplemented(501, "Not Implemented"),
  badGateway(502, "Bad Gateway"),
  serviceUnavailable(503, "Service Unavailable"),
  gatewayTimeout(504, "Gateway Timeout");

  final int code;
  final String message;

  const HTTPStatusCode(this.code, this.message);

  @override
  String toString() => '$code: $message';

  static HTTPStatusCode? fromCode(int code) {
    return HTTPStatusCode.values.firstWhere(
      (status) => status.code == code,
      orElse: () => HTTPStatusCode.internalServerError,
    );
  }
}
