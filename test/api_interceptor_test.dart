import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/network/api_interceptors.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';

void main() {
  test(
    'refreshes and rotates tokens once for concurrent unauthorized calls',
    () async {
      final secureStorage = _MemorySecureStorage();
      var refreshRequestCount = 0;
      final refreshDio =
          Dio(BaseOptions(baseUrl: 'https://test.example/api/v1/'))
            ..httpClientAdapter = _CallbackAdapter((options) async {
              refreshRequestCount++;
              final requestBody = options.data is String
                  ? jsonDecode(options.data as String)
                  : options.data;
              expect(requestBody, {'refreshToken': 'old-refresh-token'});
              return _responseBody({
                'success': true,
                'code': 'AUTH_LOGIN_SUCCESS',
                'message': 'ok',
                'data': {
                  'accessToken': 'new-access-token',
                  'refreshToken': 'rotated-refresh-token',
                },
              });
            });

      final apiDio = Dio(BaseOptions(baseUrl: 'https://test.example/api/v1/'));
      var apiRequestCount = 0;
      apiDio.httpClientAdapter = _CallbackAdapter((options) async {
        apiRequestCount++;
        if (options.headers['Authorization'] == 'Bearer new-access-token') {
          return _responseBody({'success': true});
        }
        return _responseBody({'success': false}, statusCode: 401);
      });
      apiDio.interceptors.add(
        ApiInterceptor(
          dio: apiDio,
          secureStorageHelper: secureStorage,
          refreshDioFactory: () => refreshDio,
        ),
      );

      final responses = await Future.wait([
        apiDio.get<dynamic>('users/me'),
        apiDio.get<dynamic>('users/me'),
      ]);

      expect(responses, hasLength(2));
      expect(responses.every((response) => response.statusCode == 200), isTrue);
      expect(refreshRequestCount, 1);
      expect(apiRequestCount, 4);
      expect(secureStorage.accessToken, 'new-access-token');
      expect(secureStorage.refreshToken, 'rotated-refresh-token');
    },
  );
}

class _MemorySecureStorage extends SecureStorageHelper {
  _MemorySecureStorage() : super.internal();

  String? accessToken = 'expired-access-token';
  String? refreshToken = 'old-refresh-token';

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> saveAuthenticationTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}

class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this.onRequest);

  final Future<ResponseBody> Function(RequestOptions options) onRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return onRequest(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _responseBody(Map<String, Object?> data, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
