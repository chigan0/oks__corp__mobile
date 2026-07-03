import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence for JWT access and refresh tokens.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const pendingPhoneKey = 'pending_approval_phone';
  static const pendingApprovalCodeKey = 'pending_approval_code';

  final FlutterSecureStorage _storage;

  Future<String?> getAccessToken() => _storage.read(key: accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: refreshTokenKey);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: accessTokenKey, value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: refreshTokenKey, value: token);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  Future<void> deleteAccessToken() => _storage.delete(key: accessTokenKey);

  Future<void> deleteRefreshToken() => _storage.delete(key: refreshTokenKey);

  Future<void> clear() => _storage.deleteAll();

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Persists the in-flight corporate approval request so it survives the
  /// app being closed while the user is waiting for admin confirmation.
  Future<void> savePendingApproval({
    required String phone,
    required String code,
  }) async {
    await Future.wait([
      _storage.write(key: pendingPhoneKey, value: phone),
      _storage.write(key: pendingApprovalCodeKey, value: code),
    ]);
  }

  Future<(String phone, String code)?> getPendingApproval() async {
    final phone = await _storage.read(key: pendingPhoneKey);
    final code = await _storage.read(key: pendingApprovalCodeKey);
    if (phone == null || phone.isEmpty || code == null || code.isEmpty) {
      return null;
    }
    return (phone, code);
  }

  Future<void> clearPendingApproval() async {
    await Future.wait([
      _storage.delete(key: pendingPhoneKey),
      _storage.delete(key: pendingApprovalCodeKey),
    ]);
  }
}
