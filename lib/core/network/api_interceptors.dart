import 'dart:async';

import 'package:dio/dio.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor({
    required this.dio,
    SecureStorageHelper? secureStorageHelper,
    Dio Function()? refreshDioFactory,
  }) : _secureStorageHelper =
           secureStorageHelper ?? SecureStorageHelper.instance,
       _refreshDioFactory = refreshDioFactory ?? _createRefreshDio;

  static const _retriedRequestKey = 'retriedAfterTokenRefresh';

  static Dio _createRefreshDio() {
    return Dio(
      BaseOptions(
        baseUrl: EndPoint.baseUrl,
        contentType: Headers.jsonContentType,
      ),
    );
  }

  final Dio dio;
  final SecureStorageHelper _secureStorageHelper;
  final Dio Function() _refreshDioFactory;
  Future<String>?
  _refreshInProgress; // مهمته يمنع من حدوث عمليات تحديث متزامنة  متكرره

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.data is FormData) {
      final boundary = (options.data as FormData).boundary;
      options.headers['content-type'] =
          'multipart/form-data; boundary=$boundary';
    } else {
      options.headers['Content-Type'] = 'application/json';
    }

    try {
      final token = await _secureStorageHelper.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = '${ApiKey.tokenPrefix} $token';
      }
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        requestOptions.extra[_retriedRequestKey] == true ||
        _isAuthenticationRequest(requestOptions.path)) {
      handler.next(err);
      return;
    }

    try {
      final refreshToken = await _secureStorageHelper.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        handler.next(err);
        return;
      }
      final refreshFuture = _refreshInProgress ??= _refreshAccessToken(
        refreshToken,
      );
      final newAccessToken = await refreshFuture;
      requestOptions
        ..headers['Authorization'] = '${ApiKey.tokenPrefix} $newAccessToken'
        ..extra[_retriedRequestKey] = true;

      final response = await dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      _refreshInProgress = null;
    }
  }

  Future<String> _refreshAccessToken(String refreshToken) async {
    final refreshDio = _refreshDioFactory();
    final response = await refreshDio.post<Map<String, dynamic>>(
      EndPoint.refreshToken,
      data: {SecureStorageHelper.refreshTokenKey: refreshToken},
    );
    final responseBody = response.data;
    final rawData = responseBody?['data'];
    if (responseBody?['success'] != true || rawData is! Map) {
      throw const FormatException('The token refresh response was invalid.');
    }

    final data = Map<String, dynamic>.from(rawData);
    final accessToken = data['accessToken'];
    final rotatedRefreshToken = data['refreshToken'];
    if (accessToken is! String ||
        accessToken.isEmpty ||
        rotatedRefreshToken is! String ||
        rotatedRefreshToken.isEmpty) {
      throw const FormatException('The refreshed tokens were missing.');
    }

    await _secureStorageHelper.saveAuthenticationTokens(
      accessToken: accessToken,
      refreshToken: rotatedRefreshToken,
    );
    return accessToken;
  }

  bool _isAuthenticationRequest(String path) {
    final normalizedPath = path.toLowerCase();
    return normalizedPath.endsWith(EndPoint.login.toLowerCase()) ||
        normalizedPath.endsWith(EndPoint.register.toLowerCase()) ||
        normalizedPath.endsWith(EndPoint.logout.toLowerCase()) ||
        normalizedPath.endsWith(EndPoint.refreshToken.toLowerCase());
  }
}
