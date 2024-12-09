import 'package:dio_handler_plus/exception/app_exception.dart';
import 'package:dio_handler_plus/utils/error_const.dart';

class NetworkException extends AppException {
  NetworkException({
    required super.message,
    required super.statusCode,
  });

  factory NetworkException.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return NetworkException(
          message: ErrorConst.badRequest,
          statusCode: statusCode,
        );
      case 401:
        return NetworkException(
          message: ErrorConst.unauthorised,
          statusCode: statusCode,
        );
      case 500:
        return NetworkException(
          message: ErrorConst.serverError,
          statusCode: statusCode,
        );
      default:
        return NetworkException(
          message: ErrorConst.networkError,
          statusCode: statusCode,
        );
    }
  }
}
