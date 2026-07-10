import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/api/auth_api.dart';
import '../../features/auth/auth_notifier.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/construction_objects/api/facilities_api.dart';
import '../../features/profile/api/profile_api.dart';
import '../../features/qr_generation/api/qr_generation_api.dart';
import '../../features/qr_scanning/api/qr_validation_api.dart';
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
  late final Dio qrDio;
  late final QrGenerationApi qrGenerationApi;
  late final QrValidationApi qrValidationApi;
  late final FacilitiesApi facilitiesApi;

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

    qrDio = createAuthenticatedDio(
      tokenStorage: tokenStorage,
      refreshAccessToken: () async {
        final tokens = await authRepository.refreshTokens();
        return tokens.accessToken;
      },
      onSessionExpired: authNotifier.handleSessionExpired,
      logTag: 'DioQr',
      baseUrl: ApiConfig.qrBaseUrl,
    );
    qrGenerationApi = QrGenerationApi(qrDio);
    qrValidationApi = QrValidationApi(qrDio);
    facilitiesApi = FacilitiesApi(qrDio);

    _initialized = true;
  }
}
