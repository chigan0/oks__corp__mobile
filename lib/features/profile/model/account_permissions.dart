import '../../../entities/service_type/model/service_type.dart';

/// Permission codes returned by `GET /accounts/me/` in the `permissions` array.
abstract final class AccountPermissions {
  /// Охрана (КПП).
  static const facilitiesManager = 'facilities:manager';

  /// Работники на объектах.
  static const coreSecurityStaff = 'core:security_staff';

  static const _permissionToService = {
    facilitiesManager: ServiceType.guard,
    coreSecurityStaff: ServiceType.worker,
  };

  /// Maps backend permission codes to app service roles.
  static List<ServiceType> resolveServiceTypes(Iterable<String> permissions) {
    final roles = <ServiceType>[];

    for (final permission in permissions) {
      final role = _permissionToService[permission.trim()];
      if (role != null && !roles.contains(role)) {
        roles.add(role);
      }
    }

    return roles;
  }
}
