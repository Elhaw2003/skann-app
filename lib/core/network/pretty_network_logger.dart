import 'dart:developer';
import 'package:dio/dio.dart';

/// A custom Dio interceptor that logs all HTTP traffic in a clean,
/// structured, and professional console format. No emojis.
class PrettyNetworkLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;
    final method = options.method;
    final isPasswordChange = _isPasswordChange(options.path);
    final headers = _sanitizeHeaders(options.headers);
    final body = isPasswordChange ? '[REDACTED]' : _sanitize(options.data);

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
    final data = _isPasswordChange(response.requestOptions.path)
        ? '[REDACTED]'
        : _sanitize(response.data);

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
    final data = _isPasswordChange(err.requestOptions.path)
        ? '[REDACTED]'
        : _sanitize(err.response?.data);
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

  bool _isPasswordChange(String path) =>
      path.replaceAll('\\', '/').endsWith('users/me/password');

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: entry.key.toLowerCase() == 'authorization'
            ? '[REDACTED]'
            : _sanitize(entry.value),
    };
  }

  Object? _sanitize(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _isSensitiveKey(entry.key.toString())
              ? '[REDACTED]'
              : _sanitize(entry.value),
      };
    }
    if (value is Iterable) {
      return value.map(_sanitize).toList(growable: false);
    }
    return value;
  }

  bool _isSensitiveKey(String key) {
    final normalizedKey = key.toLowerCase();
    return normalizedKey.contains('token') ||
        normalizedKey.contains('password');
  }
}
