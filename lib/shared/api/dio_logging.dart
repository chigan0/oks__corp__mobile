import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Shared Dio [LogInterceptor] for request/response debugging.
LogInterceptor createDioLogInterceptor({String tag = 'Dio'}) {
  return LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    logPrint: (message) => debugPrint('[$tag] $message'),
  );
}

void logDioException(DioException error, {String tag = 'DioError'}) {
  debugPrint('[$tag] ${error.type}');
  debugPrint('[$tag] message: ${error.message}');
  debugPrint('[$tag] method: ${error.requestOptions.method}');
  debugPrint('[$tag] url: ${error.requestOptions.uri}');
  debugPrint('[$tag] status: ${error.response?.statusCode}');
  debugPrint('[$tag] response: ${error.response?.data}');
}
