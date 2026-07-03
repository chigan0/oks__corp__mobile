/// OKS ID HTTP API configuration.
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.id.oks.group/api/v1',
  );

  static const profilePath = '/accounts/me/';
  static const refreshPath = '/auth/refresh/';
  static const phoneApprovalPath = '/auth/phone/approval/';
  static const verifyPath = '/auth/verify/';

  static String approvalStatusPath(String code) => '/auth/approval/$code/status/';

  static const refreshTtlDays = 30;
  static const approvalPollInterval = Duration(seconds: 3);

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}
