import 'package:dio/dio.dart';

import '../../../shared/api/api_config.dart';
import '../../../shared/api/dio_logging.dart';
import '../model/approval_status.dart';
import '../model/auth_tokens.dart';
import '../model/phone_approval_response.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<PhoneApprovalResponse> requestPhoneApproval(String phone) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConfig.phoneApprovalPath,
        data: {'phone': phone},
      );

      return PhoneApprovalResponse.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      logDioException(error, tag: 'AuthApi.requestPhoneApproval');
      rethrow;
    }
  }

  Future<ApprovalStatusResponse> getApprovalStatus(String code) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConfig.approvalStatusPath(code),
      );

      return ApprovalStatusResponse.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      logDioException(error, tag: 'AuthApi.getApprovalStatus');
      rethrow;
    }
  }

  Future<AuthTokens> verifyApproval(String code) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConfig.verifyPath,
        data: {
          'type': 'approval',
          'code': code,
          'refreshTtlDays': ApiConfig.refreshTtlDays,
        },
      );

      return AuthTokens.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      logDioException(error, tag: 'AuthApi.verifyApproval');
      rethrow;
    }
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConfig.refreshPath,
        data: {
          'refreshToken': refreshToken,
          'refreshTtlDays': ApiConfig.refreshTtlDays,
        },
      );

      return AuthTokens.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      logDioException(error, tag: 'AuthApi.refresh');
      rethrow;
    }
  }
}
