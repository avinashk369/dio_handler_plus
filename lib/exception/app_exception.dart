abstract class AppException implements Exception {
  final String message;
  final int statusCode;

  AppException({
    required this.message,
    required this.statusCode,
  });
}
