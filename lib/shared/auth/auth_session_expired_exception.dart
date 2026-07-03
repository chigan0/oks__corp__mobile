/// Thrown when refresh token flow fails and the user must sign in again.
class AuthSessionExpiredException implements Exception {
  AuthSessionExpiredException([this.message = 'Session expired']);

  final String message;

  @override
  String toString() => message;
}
