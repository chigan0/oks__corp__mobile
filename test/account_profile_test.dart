import 'package:flutter_test/flutter_test.dart';
import 'package:oks_qr_mobile/entities/service_type/model/service_type.dart';
import 'package:oks_qr_mobile/features/profile/model/account_permissions.dart';
import 'package:oks_qr_mobile/features/profile/model/account_profile.dart';

void main() {
  group('AccountPermissions', () {
    test('maps guard permission to guard service', () {
      expect(
        AccountPermissions.resolveServiceTypes(['facilities:manager']),
        [ServiceType.guard],
      );
    });

    test('maps worker permission to worker service', () {
      expect(
        AccountPermissions.resolveServiceTypes(['core:security_staff']),
        [ServiceType.worker],
      );
    });

    test('ignores unknown permissions', () {
      expect(
        AccountPermissions.resolveServiceTypes(['unknown:role']),
        isEmpty,
      );
    });
  });

  group('AccountProfile', () {
    test('parses permissions as string list', () {
      final profile = AccountProfile.fromJson({
        'fullName': 'Test User',
        'phone': '+77001234567',
        'permissions': ['facilities:manager'],
      });

      expect(profile.permissions, ['facilities:manager']);
      expect(profile.assignedServiceTypes, [ServiceType.guard]);
    });

    test('parses permissions as object list', () {
      final profile = AccountProfile.fromJson({
        'fullName': 'Test User',
        'phone': '+77001234567',
        'permissions': [
          {'code': 'core:security_staff'},
        ],
      });

      expect(profile.permissions, ['core:security_staff']);
      expect(profile.assignedServiceTypes, [ServiceType.worker]);
    });
  });
}
