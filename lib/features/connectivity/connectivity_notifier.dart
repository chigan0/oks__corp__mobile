import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks device network availability for the global offline overlay.
class ConnectivityNotifier extends ChangeNotifier {
  ConnectivityNotifier({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;
  bool _initialized = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    _subscription ??=
        _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    await _refreshConnectivity();
  }

  @visibleForTesting
  static bool hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;

    return results.any(
      (result) =>
          result != ConnectivityResult.none &&
          result != ConnectivityResult.bluetooth,
    );
  }

  Future<void> _refreshConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _applyConnectivity(results);
    } catch (error, stackTrace) {
      debugPrint('[ConnectivityNotifier] checkConnectivity failed: $error');
      debugPrint('$stackTrace');
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    _applyConnectivity(results);
  }

  void _applyConnectivity(List<ConnectivityResult> results) {
    final online = hasConnection(results);
    final changed = _isOnline != online || !_initialized;

    _isOnline = online;
    _initialized = true;

    if (changed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
