import 'dart:math';

import '../../../entities/user_profile/repository/mock_user_repository.dart';
import '../../../entities/worker/model/scanned_worker.dart';

class ScanApiResult {
  const ScanApiResult({
    required this.isValid,
    required this.worker,
  });

  final bool isValid;
  final ScannedWorker worker;
}

class MockScanApi {
  MockScanApi._();

  static final MockScanApi instance = MockScanApi._();
  final _random = Random();

  Future<ScanApiResult> verifyQrCode(String qrData) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final profile = MockUserRepository.instance.workerProfile;
    final objectName = _extractObjectName(qrData);

    return ScanApiResult(
      isValid: _random.nextBool(),
      worker: ScannedWorker(
        fullName: profile.fullName,
        company: profile.company,
        iin: profile.iin,
        phone: profile.phone,
        objectName: objectName,
      ),
    );
  }

  String _extractObjectName(String qrData) {
    final parts = qrData.split('|');
    if (parts.length >= 4) return parts[3];
    return "Kainar Village";
  }
}
