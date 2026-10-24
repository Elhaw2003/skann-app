import 'dart:developer';
import 'package:dio/dio.dart';

/// A custom Dio interceptor that logs all HTTP traffic in a clean,
/// structured, and professional console format. No emojis.
class PrettyNetworkLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;
    final method = options.method;
    final headers = options.headers;
    final body = options.data;

    log(
      '\n========== OUTGOING REQUEST ==========\n'
      'Method : $method\n'
      'URL    : $uri\n'
      'Headers: $headers\n'
      'Payload: $body\n'
      '======================================\n',
      name: 'HTTP',
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    final statusCode = response.statusCode;
    final data = response.data;

    log(
      '\n========== RECEIVED RESPONSE ==========\n'
      'Status : $statusCode\n'
      'Method : $method\n'
      'URL    : $uri\n'
      'Data   : $data\n'
      '=======================================\n',
      name: 'HTTP',
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final uri = err.requestOptions.uri;
    final method = err.requestOptions.method;
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    final message = err.message;

    log(
      '\n========== HTTP ERROR ==========\n'
      'Status : $statusCode\n'
      'Method : $method\n'
      'URL    : $uri\n'
      'Message: $message\n'
      'Data   : $data\n'
      '================================\n',
      name: 'HTTP',
    );

    super.onError(err, handler);
  }
}
