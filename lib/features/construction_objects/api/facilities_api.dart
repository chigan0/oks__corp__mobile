import 'package:dio/dio.dart';

import '../../../entities/construction_object/model/construction_object.dart';
import '../../../entities/construction_object/model/facility_details.dart';
import '../../../entities/construction_object/model/facility_document.dart';
import '../../../shared/api/api_config.dart';
import '../../../shared/api/dio_logging.dart';

enum FacilitiesErrorType { notFound, network, unknown }

class FacilitiesApiException implements Exception {
  const FacilitiesApiException(this.type, this.message);

  final FacilitiesErrorType type;
  final String message;

  factory FacilitiesApiException.fromDioException(DioException error) {
    if (error.response?.statusCode == 404) {
      return const FacilitiesApiException(
        FacilitiesErrorType.notFound,
        'Объект не найден',
      );
    }

    if (_isNetworkFailure(error.type)) {
      return const FacilitiesApiException(
        FacilitiesErrorType.network,
        'Нет подключения к сети. Проверьте интернет и попробуйте снова',
      );
    }

    return const FacilitiesApiException(
      FacilitiesErrorType.unknown,
      'Не удалось загрузить данные объекта',
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

class FacilitiesApi {
  FacilitiesApi(this._dio);

  final Dio _dio;

  Future<List<ConstructionObject>> fetchFacilities({bool? hasAccess}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConfig.facilitiesPath,
        queryParameters: {
          if (hasAccess != null) 'hasAccess': hasAccess,
        },
      );

      final items = response.data ?? const [];
      return items
          .map((item) => ConstructionObject.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      logDioException(error, tag: 'FacilitiesApi.fetchFacilities');
      throw FacilitiesApiException.fromDioException(error);
    }
  }

  Future<FacilityDetails> fetchFacilityDetails(String facilityUuid) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConfig.facilityDetailsPath(facilityUuid),
      );

      return FacilityDetails.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      logDioException(error, tag: 'FacilitiesApi.fetchFacilityDetails');
      throw FacilitiesApiException.fromDioException(error);
    }
  }

  Future<List<FacilityDocument>> fetchFacilityDocuments(String facilityUuid) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConfig.facilityDocumentsPath(facilityUuid),
      );

      final items = response.data ?? const [];
      return items
          .map((item) => FacilityDocument.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      logDioException(error, tag: 'FacilitiesApi.fetchFacilityDocuments');
      throw FacilitiesApiException.fromDioException(error);
    }
  }
}
