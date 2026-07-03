import 'package:dio/dio.dart';

import 'auth_session_expired_exception.dart';
import 'token_storage.dart';

typedef RefreshAccessTokenCallback = Future<String> Function();
typedef SessionExpiredCallback = Future<void> Function();

/// Attaches JWT access tokens and transparently refreshes them on 401 responses.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required RefreshAccessTokenCallback refreshAccessToken,
    required SessionExpiredCallback onSessionExpired,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _refreshAccessToken = refreshAccessToken,
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final RefreshAccessTokenCallback _refreshAccessToken;
  final SessionExpiredCallback _onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicAuthEndpoint(options.path)) {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRefresh = err.response?.statusCode == 401 &&
        !_isPublicAuthEndpoint(err.requestOptions.path) &&
        err.requestOptions.extra['skipAuthRefresh'] != true;

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    try {
      final accessToken = await _refreshAccessToken();
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } catch (_) {
      await _onSessionExpired();
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: AuthSessionExpiredException(),
        ),
      );
    }
  }

  bool _isPublicAuthEndpoint(String path) {
    return path.contains('/auth/refresh') ||
        path.contains('/phone/approval') ||
        path.contains('/approval/') ||
        path.contains('/verify');
  }
}
