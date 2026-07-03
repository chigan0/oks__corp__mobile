class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final accessToken = _readToken(json, const [
      'access_token',
      'accessToken',
    ]);
    final refreshToken = _readToken(json, const [
      'refresh_token',
      'refreshToken',
    ]);

    if (accessToken == null || refreshToken == null) {
      throw FormatException(
        'Missing access_token or refresh_token in auth response',
      );
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  final String accessToken;
  final String refreshToken;

  static String? _readToken(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return _readToken(data, keys);
    }

    final tokens = json['tokens'];
    if (tokens is Map<String, dynamic>) {
      return _readToken(tokens, keys);
    }

    return null;
  }
}
