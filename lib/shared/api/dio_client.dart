import 'package:dio/dio.dart';

import '../auth/auth_interceptor.dart';
import '../auth/token_storage.dart';
import 'api_config.dart';
import 'dio_logging.dart';

/// Plain Dio client for unauthenticated requests (login / refresh).
Dio createPublicDio({String logTag = 'DioPublic'}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(createDioLogInterceptor(tag: logTag));
  return dio;
}

/// Authenticated Dio client with JWT attach + automatic refresh on 401.
Dio createAuthenticatedDio({
  required TokenStorage tokenStorage,
  required RefreshAccessTokenCallback refreshAccessToken,
  required SessionExpiredCallback onSessionExpired,
  String logTag = 'DioAuth',
}) {
  final dio = createPublicDio(logTag: logTag);

  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      tokenStorage: tokenStorage,
      refreshAccessToken: refreshAccessToken,
      onSessionExpired: onSessionExpired,
    ),
  );

  return dio;
}
