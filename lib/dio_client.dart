import 'package:dio/dio.dart';
import 'package:dio_handler_plus/interceptors/retry_interceptor.dart';
import 'package:dio_handler_plus/model/api_response.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  final List<Interceptor> interceptors;
  final String baseUrl;

  DioClient(this.baseUrl, {required this.interceptors}) {
    _initializeDioClient();
  }

  static const int maxRetries = 3;
  static const int retryDelay = 1;
  late final Dio dio;

  void _initializeDioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    dio.interceptors.addAll([
      RetryInterceptor(
        dio: dio,
        options: RetryOptions(
          retries: maxRetries,
          retryInterval: const Duration(seconds: retryDelay),
          retryEvaluator: (error) async {
            if (error.type == DioExceptionType.connectionError ||
                error.type == DioExceptionType.connectionTimeout ||
                (error.response?.statusCode != null &&
                    error.response!.statusCode! >= 500)) {
              return true;
            }
            return false;
          },
        ),
      ),
      ...interceptors,
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
      )
    ]);
  }

  static ApiResponse handleDioError(DioException error) {
    String message = "";
    dynamic data;
    int code = 200;
    String success = "false";
    if (error.response?.data != null) {
      final responseData = error.response!.data;
      code = responseData["code"] ?? 200;
      message = responseData["message"] ?? "Unknown error occurred";
      data = responseData["data"] ?? "";
      success = responseData["success"] ?? "false";
    } else {
      switch (error.type) {
        case DioExceptionType.cancel:
          message = "Request to API server was cancelled";
          break;
        case DioExceptionType.connectionError:
          message = "Failed connection to API server";
        case DioExceptionType.connectionTimeout:
          message = "Connection timed out";
        case DioExceptionType.unknown:
          message = "A Server Error Occured!";
          break;
        case DioExceptionType.receiveTimeout:
          message = "Receive timeout in connection with API server";
          break;
        case DioExceptionType.badResponse:
          message =
              "Received invalid status code: ${error.response?.statusCode}";
          break;
        case DioExceptionType.sendTimeout:
          message = "Send timeout in connection with API server";
          break;
        case DioExceptionType.badCertificate:
          message = "Incorrect certificate";
          break;
      }
    }
    return ApiResponse(
      code: code,
      message: message,
      data: data,
      success: success,
    );
  }
}
