import 'package:dio/dio.dart';

import '../../../shared/api/api_config.dart';
import '../../../shared/api/dio_logging.dart';
import '../model/facility_code_response.dart';

enum QrGenerationErrorType { forbidden, notFound, network, unknown }

class QrGenerationException implements Exception {
  const QrGenerationException(this.type, this.message);

  final QrGenerationErrorType type;
  final String message;

  factory QrGenerationException.fromDioException(DioException error) {
    switch (error.response?.statusCode) {
      case 403:
        return const QrGenerationException(
          QrGenerationErrorType.forbidden,
          'У вас нет допуска на этот объект',
        );
      case 404:
        return const QrGenerationException(
          QrGenerationErrorType.notFound,
          'Объект не найден',
        );
    }

    if (_isNetworkFailure(error.type)) {
      return const QrGenerationException(
        QrGenerationErrorType.network,
        'Нет подключения к сети. Проверьте интернет и попробуйте снова',
      );
    }

    return const QrGenerationException(
      QrGenerationErrorType.unknown,
      'Не удалось получить QR-код. Попробуйте позже',
    );
  }

  static bool _isNetworkFailure(DioExceptionType type) {
    return type == DioExceptionType.connectionError ||
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout;
  }

  @override
  String toString() => message;
}

class QrGenerationApi {
  QrGenerationApi(this._dio);

  final Dio _dio;

  Future<FacilityCodeResponse> requestFacilityCode(String facilityUuid) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConfig.facilityCodePath(facilityUuid),
      );

      return FacilityCodeResponse.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      logDioException(error, tag: 'QrGenerationApi.requestFacilityCode');
      throw QrGenerationException.fromDioException(error);
    }
  }
}
