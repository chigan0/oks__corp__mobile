import 'package:dio/dio.dart';

import '../../../entities/worker/model/scanned_worker.dart';
import '../../../shared/api/api_config.dart';
import '../../../shared/api/dio_logging.dart';

enum QrValidationErrorType { notFound, network, unknown }

class QrValidationException implements Exception {
  const QrValidationException(this.type, this.message);

  final QrValidationErrorType type;
  final String message;

  factory QrValidationException.fromDioException(DioException error) {
    if (error.response?.statusCode == 404) {
      return const QrValidationException(
        QrValidationErrorType.notFound,
        'Код недействителен, использован или устарел',
      );
    }

    if (_isNetworkFailure(error.type)) {
      return const QrValidationException(
        QrValidationErrorType.network,
        'Нет подключения к сети. Проверьте интернет и попробуйте снова',
      );
    }

    return const QrValidationException(
      QrValidationErrorType.unknown,
      'Не удалось проверить код. Попробуйте позже',
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

class QrValidationApi {
  QrValidationApi(this._dio);

  final Dio _dio;

  Future<ScannedWorker> validate(String code) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConfig.qrValidatePath,
        data: {'code': code},
      );

      return ScannedWorker.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      logDioException(error, tag: 'QrValidationApi.validate');
      throw QrValidationException.fromDioException(error);
    }
  }
}
