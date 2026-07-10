import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api/qr_generation_api.dart';

enum QrGenerationStatus { loading, active, error }

/// Requests a one-time facility access code and silently re-requests a new
/// one each time its lifetime countdown reaches zero, so the QR on screen
/// never visibly expires while the sheet is open.
class QrGenerationNotifier extends ChangeNotifier {
  QrGenerationNotifier({
    required QrGenerationApi api,
    required String facilityUuid,
  })  : _api = api,
        _facilityUuid = facilityUuid {
    generate();
  }

  /// Fixed client-side display lifetime for a code, independent of the
  /// `expiresIn` the backend reports — the code is refreshed on this cadence
  /// regardless, so it's always well within whatever window the server allows.
  static const _codeLifetime = Duration(seconds: 30);

  final QrGenerationApi _api;
  final String _facilityUuid;

  Timer? _countdownTimer;
  QrGenerationStatus _status = QrGenerationStatus.loading;
  String? _code;
  int _remainingSeconds = 0;
  QrGenerationException? _error;

  QrGenerationStatus get status => _status;
  String? get code => _code;
  int get remainingSeconds => _remainingSeconds;
  QrGenerationException? get error => _error;

  /// Fetches a fresh code and shows the loading skeleton first.
  /// Use this for the initial load and the manual "retry" action.
  Future<void> generate() async {
    _countdownTimer?.cancel();
    _status = QrGenerationStatus.loading;
    _error = null;
    notifyListeners();
    await _fetchCode();
  }

  Future<void> _fetchCode() async {
    try {
      final response = await _api.requestFacilityCode(_facilityUuid);
      _code = response.code;
      _remainingSeconds = _codeLifetime.inSeconds;
      _status = QrGenerationStatus.active;
      _error = null;
      notifyListeners();
      _startCountdown();
    } on QrGenerationException catch (error) {
      _error = error;
      _status = QrGenerationStatus.error;
      notifyListeners();
    } catch (error) {
      _error = const QrGenerationException(
        QrGenerationErrorType.unknown,
        'Не удалось получить QR-код. Попробуйте позже',
      );
      _status = QrGenerationStatus.error;
      notifyListeners();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        // Keep showing the current code until the replacement arrives —
        // no visible "expired" state.
        timer.cancel();
        _fetchCode();
      } else {
        _remainingSeconds -= 1;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
