import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:oks_qr_mobile/features/connectivity/connectivity_notifier.dart';

void main() {
  group('ConnectivityNotifier.hasConnection', () {
    test('returns false for none', () {
      expect(
        ConnectivityNotifier.hasConnection([ConnectivityResult.none]),
        isFalse,
      );
    });

    test('returns true for mobile data', () {
      expect(
        ConnectivityNotifier.hasConnection([ConnectivityResult.mobile]),
        isTrue,
      );
    });

    test('returns true for wifi', () {
      expect(
        ConnectivityNotifier.hasConnection([ConnectivityResult.wifi]),
        isTrue,
      );
    });

    test('returns false for empty results', () {
      expect(
        ConnectivityNotifier.hasConnection([]),
        isFalse,
      );
    });
  });
}
