import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_handler_plus/dio_client.dart';
import 'package:dio_handler_plus/model/api_response.dart';

class NetworkManager {
  final DioClient dioClient;

  NetworkManager({required this.dioClient});

  static Future<ApiResponse> _request({
    required String method,
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!await networkMonitor.checkConnection()) {
      throw ApiResponse(
        message: "No internet connection",
        data: null,
        code: 500,
        success: "false",
      );
    }

    final completer = Completer<ApiResponse>();
    late ApiResponse networkResponse;
    StreamSubscription? networkSubscription;

    networkSubscription = networkMonitor.onConnectivityChanged.listen(
      (hasConnection) {
        if (!hasConnection && !completer.isCompleted) {
          networkResponse = ApiResponse(
            message: "Internet connection lost",
            data: null,
            failed: true,
            code: 500,
            success: "false",
          );
          completer.completeError(networkResponse);
        }
      },
    );
    try {
      final response = await dioClient.dio.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      networkResponse = _handleResponse(response);
      completer.complete(networkResponse);
    } on DioException catch (e) {
      if (!completer.isCompleted) {
        networkResponse = DioClient.handleDioError(e);
        networkResponse.failed = true;
        completer.completeError(networkResponse);
        return networkResponse;
      }
    } on ApiResponse catch (e) {
      if (!completer.isCompleted) {
        networkResponse = e;
        networkResponse.failed = true;
        completer.completeError(networkResponse);
        return networkResponse;
      }
    } catch (e) {
      if (!completer.isCompleted) {
        networkResponse = ApiResponse(
          message: "An unexpected error occurred",
          data: null,
          code: 500,
          success: "false",
          failed: true,
        );
        completer.completeError(networkResponse);
        return networkResponse;
      }
    } finally {
      await networkSubscription.cancel();
    }

    return networkResponse;
  }

  static Future<ApiResponse> get({
    required String url,
    Map<String, dynamic>? extraQuery,
  }) =>
      _request(
        method: 'GET',
        url: url,
        queryParameters: extraQuery,
      );

  static Future<ApiResponse> post({
    required String url,
    Map<String, dynamic>? data,
  }) =>
      _request(
        method: 'POST',
        url: url,
        data: data,
      );

  static Future<ApiResponse> patch({
    required String url,
    Map<String, dynamic>? data,
  }) =>
      _request(
        method: 'PATCH',
        url: url,
        data: data,
      );

  static Future<ApiResponse> put({
    required String url,
    Map<String, dynamic>? data,
  }) =>
      _request(
        method: 'PUT',
        url: url,
        data: data,
      );

  static Future<ApiResponse> delete({required String url}) => _request(
        method: 'DELETE',
        url: url,
      );

  ApiResponse _handleResponse(Response response) {
    final body = response.data;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiResponse(
        data: body,
      );
    }
    throw ApiResponse(failed: true);
  }
}
