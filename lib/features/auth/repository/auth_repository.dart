import 'package:flutter/foundation.dart';

import '../api/auth_api.dart';
import '../model/approval_status.dart';
import '../model/auth_tokens.dart';
import '../model/phone_approval_response.dart';
import '../../../shared/auth/token_storage.dart';

class AuthRepository {
  AuthRepository({
    required AuthApi authApi,
    required TokenStorage tokenStorage,
  })  : _authApi = authApi,
        _tokenStorage = tokenStorage;

  final AuthApi _authApi;
  final TokenStorage _tokenStorage;

  Future<PhoneApprovalResponse> requestPhoneApproval(String phone) =>
      _authApi.requestPhoneApproval(phone);

  Future<ApprovalStatusResponse> getApprovalStatus(String code) =>
      _authApi.getApprovalStatus(code);

  Future<AuthTokens> verifyApproval(String code) async {
    try {
      final tokens = await _authApi.verifyApproval(code);
      await _saveTokens(tokens);
      debugPrint('[AuthRepository] Approval verification succeeded');
      return tokens;
    } catch (error, stackTrace) {
      debugPrint('[AuthRepository] Approval verification failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<AuthTokens> refreshTokens() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('Refresh token is missing');
    }

    try {
      final tokens = await _authApi.refresh(refreshToken);
      await _saveTokens(tokens);
      debugPrint('[AuthRepository] Refresh succeeded, tokens updated');
      return tokens;
    } catch (error, stackTrace) {
      debugPrint('[AuthRepository] Refresh failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<void> _saveTokens(AuthTokens tokens) => _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

  Future<void> logout() => _tokenStorage.clear();

  Future<bool> hasSession() => _tokenStorage.hasAccessToken();

  Future<void> savePendingApproval({
    required String phone,
    required String code,
  }) =>
      _tokenStorage.savePendingApproval(phone: phone, code: code);

  Future<(String phone, String code)?> getPendingApproval() =>
      _tokenStorage.getPendingApproval();

  Future<void> clearPendingApproval() => _tokenStorage.clearPendingApproval();
}
