import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../shared/api/dio_logging.dart';
import '../../shared/auth/auth_session_expired_exception.dart';
import 'model/approval_status.dart';
import 'model/auth_flow_state.dart';
import 'model/registration_draft.dart';
import 'repository/auth_repository.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._authRepository) {
    _restoreSession();
  }

  final AuthRepository _authRepository;

  AuthFlowState _state = AuthFlowState.initial;
  String? _errorMessage;
  String? _denialReason;
  String? _phone;
  String? _approvalCode;
  RegistrationDraft? _pendingRegistration;
  bool _sessionChecked = false;

  AuthFlowState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get denialReason => _denialReason;
  String? get phone => _phone;
  String? get approvalCode => _approvalCode;
  RegistrationDraft? get pendingRegistration => _pendingRegistration;

  bool get isAuthenticated => _state == AuthFlowState.authenticated;
  bool get isInitialized => _sessionChecked;
  bool get isSubmittingPhone => _state == AuthFlowState.submittingPhone;
  bool get isWaitingForApproval => _state == AuthFlowState.waitingForApproval;
  bool get isDenied => _state == AuthFlowState.denied;

  bool get shouldStopPolling =>
      _state == AuthFlowState.authenticated || _state == AuthFlowState.denied;

  static const maxPhoneAttempts = 5;
  static const phoneLockDuration = Duration(seconds: 65);

  int _failedPhoneAttempts = 0;
  DateTime? _phoneLockExpiresAt;
  Timer? _phoneLockTimer;

  bool get isPhoneLocked {
    if (_failedPhoneAttempts < maxPhoneAttempts) return false;
    if (_phoneLockExpiresAt == null) return true;
    return DateTime.now().isBefore(_phoneLockExpiresAt!);
  }

  int? get phoneLockSecondsRemaining {
    if (!isPhoneLocked || _phoneLockExpiresAt == null) return null;

    final remaining = _phoneLockExpiresAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  void _registerFailedPhoneAttempt() {
    _failedPhoneAttempts++;
    if (_failedPhoneAttempts >= maxPhoneAttempts) {
      _startPhoneLockTimer();
    }
  }

  void _startPhoneLockTimer() {
    _phoneLockExpiresAt = DateTime.now().add(phoneLockDuration);
    _phoneLockTimer?.cancel();
    _phoneLockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isPhoneLocked) {
        notifyListeners();
        return;
      }
      _clearPhoneLock();
      notifyListeners();
    });
  }

  void _clearPhoneLock() {
    _phoneLockTimer?.cancel();
    _phoneLockTimer = null;
    _phoneLockExpiresAt = null;
    _failedPhoneAttempts = 0;
  }

  Future<void> _restoreSession() async {
    final hasSession = await _authRepository.hasSession();
    if (hasSession) {
      _state = AuthFlowState.authenticated;
    } else {
      final pending = await _authRepository.getPendingApproval();
      if (pending != null) {
        final (phone, code) = pending;
        _phone = phone;
        _approvalCode = code;
        _state = AuthFlowState.waitingForApproval;
      } else {
        _state = AuthFlowState.initial;
      }
    }
    _sessionChecked = true;
    notifyListeners();
  }

  /// Requests corporate approval for the given phone and starts the polling flow.
  Future<void> submitPhone(String phone) async {
    if (isPhoneLocked) {
      _errorMessage =
          'Слишком много неудачных попыток. Попробуйте позже.';
      _state = AuthFlowState.error;
      notifyListeners();
      return;
    }

    final normalizedPhone = phone.trim();
    _errorMessage = null;
    _denialReason = null;
    _approvalCode = null;
    _phone = normalizedPhone;
    _pendingRegistration = RegistrationDraft(phone: normalizedPhone);
    _state = AuthFlowState.submittingPhone;
    notifyListeners();

    try {
      final response = await _authRepository.requestPhoneApproval(normalizedPhone);
      _clearPhoneLock();
      _approvalCode = response.code;
      _state = AuthFlowState.waitingForApproval;
      await _authRepository.savePendingApproval(
        phone: normalizedPhone,
        code: response.code,
      );
    } on DioException catch (error, stackTrace) {
      logDioException(error, tag: 'AuthNotifier.submitPhone');
      debugPrint('[AuthNotifier] stackTrace: $stackTrace');
      _registerFailedPhoneAttempt();
      _pendingRegistration = null;
      _state = AuthFlowState.error;
      _errorMessage = _mapError(error);
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('[AuthNotifier] submitPhone failed: $error');
      debugPrint('[AuthNotifier] stackTrace: $stackTrace');
      _registerFailedPhoneAttempt();
      _pendingRegistration = null;
      _state = AuthFlowState.error;
      _errorMessage = _mapError(error);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> pollApprovalStatus() async {
    if (_state != AuthFlowState.waitingForApproval || _approvalCode == null) {
      return;
    }

    try {
      final response =
          await _authRepository.getApprovalStatus(_approvalCode!);

      switch (response.status) {
        case ApprovalStatusType.pending:
          return;
        case ApprovalStatusType.denied:
          _denialReason = response.reason;
          _state = AuthFlowState.denied;
          await _authRepository.clearPendingApproval();
          notifyListeners();
          return;
        case ApprovalStatusType.approved:
          await _verifyApprovalAndAuthenticate();
      }
    } on DioException catch (error, stackTrace) {
      logDioException(error, tag: 'AuthNotifier.pollApprovalStatus');
      debugPrint('[AuthNotifier] stackTrace: $stackTrace');
      _state = AuthFlowState.error;
      _errorMessage = _mapError(error);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('[AuthNotifier] pollApprovalStatus failed: $error');
      debugPrint('[AuthNotifier] stackTrace: $stackTrace');
      _state = AuthFlowState.error;
      _errorMessage = _mapError(error);
      notifyListeners();
    }
  }

  Future<void> _verifyApprovalAndAuthenticate() async {
    final code = _approvalCode;
    if (code == null) {
      throw StateError('Approval code is missing');
    }

    try {
      await _authRepository.verifyApproval(code);
      await _authRepository.clearPendingApproval();
      _approvalCode = null;
      _pendingRegistration = null;
      _state = AuthFlowState.authenticated;
      notifyListeners();
    } on AuthSessionExpiredException catch (error) {
      _state = AuthFlowState.error;
      _errorMessage = error.message;
      notifyListeners();
      rethrow;
    } on DioException catch (error, stackTrace) {
      logDioException(error, tag: 'AuthNotifier.verifyApproval');
      debugPrint('[AuthNotifier] stackTrace: $stackTrace');
      _state = AuthFlowState.error;
      _errorMessage = _mapError(error);
      notifyListeners();
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('[AuthNotifier] verifyApproval failed: $error');
      debugPrint('[AuthNotifier] stackTrace: $stackTrace');
      _state = AuthFlowState.error;
      _errorMessage = _mapError(error);
      notifyListeners();
      rethrow;
    }
  }

  void resetApprovalFlow() {
    _approvalCode = null;
    _denialReason = null;
    _errorMessage = null;
    _state = AuthFlowState.initial;
    _authRepository.clearPendingApproval();
    notifyListeners();
  }

  Future<void> logout({bool notify = true}) async {
    await _authRepository.logout();
    _state = AuthFlowState.initial;
    _errorMessage = null;
    _denialReason = null;
    _approvalCode = null;
    _pendingRegistration = null;
    _phone = null;
    _clearPhoneLock();
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> handleSessionExpired() => logout();

  String _mapError(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Нет подключения к интернету. Проверьте соединение и попробуйте снова.';
      }

      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? data['detail'];
        if (message is String && message.isNotEmpty) {
          return statusCode != null
              ? 'HTTP $statusCode: $message'
              : message;
        }
      }

      if (statusCode != null) {
        return 'HTTP $statusCode: ${error.message ?? 'Не удалось выполнить вход'}';
      }

      return error.message ?? 'Не удалось выполнить вход';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _phoneLockTimer?.cancel();
    super.dispose();
  }
}
