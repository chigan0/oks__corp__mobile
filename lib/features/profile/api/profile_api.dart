import 'package:dio/dio.dart';

import '../../../shared/api/api_config.dart';
import '../../../shared/api/dio_logging.dart';
import '../model/account_profile.dart';

class ProfileApi {
  ProfileApi(this._dio);

  final Dio _dio;

  Future<AccountProfile> fetchProfile() async {
    try {
      final response = await _dio.get<dynamic>(ApiConfig.profilePath);
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw FormatException('Unexpected profile response shape: $data');
      }

      return AccountProfile.fromJson(data);
    } on DioException catch (error) {
      logDioException(error, tag: 'ProfileApi.fetchProfile');
      throw Exception(
        'HTTP ${error.response?.statusCode}: '
        '${error.response?.data ?? error.message}',
      );
    }
  }
}
