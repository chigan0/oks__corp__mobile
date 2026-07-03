import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/api/auth_api.dart';
import '../../features/auth/auth_notifier.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/profile/api/profile_api.dart';
import '../../shared/api/api_config.dart';
import '../../shared/api/dio_client.dart';
import '../../shared/auth/token_storage.dart';

/// Wires shared network/auth primitives with feature-layer auth logic.
class AppDependencies {
  AppDependencies._();

  static final AppDependencies instance = AppDependencies._();

  late final TokenStorage tokenStorage;
  late final AuthRepository authRepository;
  late final AuthNotifier authNotifier;
  late final ProfileApi profileApi;
  late final Dio publicDio;
  late final Dio authenticatedDio;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    debugPrint('[AppDependencies] API base URL: ${ApiConfig.baseUrl}');

    tokenStorage = TokenStorage();
    publicDio = createPublicDio();
    authRepository = AuthRepository(
      authApi: AuthApi(publicDio),
      tokenStorage: tokenStorage,
    );
    authNotifier = AuthNotifier(authRepository);

    authenticatedDio = createAuthenticatedDio(
      tokenStorage: tokenStorage,
      refreshAccessToken: () async {
        final tokens = await authRepository.refreshTokens();
        return tokens.accessToken;
      },
      onSessionExpired: authNotifier.handleSessionExpired,
    );

    profileApi = ProfileApi(authenticatedDio);

    _initialized = true;
  }
}
