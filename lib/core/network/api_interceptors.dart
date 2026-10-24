import 'package:dio/dio.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.data is FormData) {
      // Explicitly write multipart/form-data with the FormData boundary.
      // Relying on Dio to auto-inject the boundary is unreliable — the server
      // ends up receiving title:null because it can't parse the body.
      // We read the boundary directly from the FormData object so the header
      // always matches the actual body delimiter.
      final boundary = (options.data as FormData).boundary;
      options.headers['content-type'] =
          'multipart/form-data; boundary=$boundary';
    } else {
      options.headers['Content-Type'] = 'application/json';
    }

    final token = await SecureStorageHelper.instance.getAccessToken();
    if (token != null) {
      options.headers["Authorization"] = '${ApiKey.tokenPrefix} $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized by refreshing the token
    if (err.response?.statusCode == 401) {
      final refreshToken = await SecureStorageHelper.instance.getRefreshToken();
      final accessToken = await SecureStorageHelper.instance.getAccessToken();

      if (refreshToken != null && accessToken != null) {
        try {
          // Use a fresh Dio instance to avoid interceptor loops
          final dio = Dio();
          final response = await dio.post(
            '${EndPoint.baseUrl}${EndPoint.refreshToken}',
            data: {
              SecureStorageHelper.accessTokenKey: accessToken,
              SecureStorageHelper.refreshTokenKey: refreshToken,
            },
          );

          // Extract new tokens
          final newToken = response.data["token"];
          final newRefreshToken = response.data["refreshToken"];
          final newExpiresAt = response.data["expiresOn"];
          final newRefreshTokenExpiresOn =
              response.data["refreshTokenExpiresOn"];

          // Persist new tokens
          await SecureStorageHelper.instance.saveTokens(
            accessToken: newToken,
            refreshToken: newRefreshToken,
            expiresAt: newExpiresAt,
            refreshTokenExpiresOn: newRefreshTokenExpiresOn,
          );

          // Update the failed request's Authorization header
          err.requestOptions.headers['Authorization'] =
              '${ApiKey.tokenPrefix} $newToken';

          // Retry the original request with the new token
          final retryDio = Dio();
          final retryResponse = await retryDio.fetch(err.requestOptions);

          // Resolve with the successful retry response
          return handler.resolve(retryResponse);
        } catch (e) {
          // If refresh itself fails (e.g. refresh token expired),
          // propagate the error. Consider triggering a global logout here.
          return handler.next(err);
        }
      }
    }
    // For non-401 errors, continue the error chain
    return handler.next(err);
  }
}
