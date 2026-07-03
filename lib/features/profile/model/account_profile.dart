import '../../../entities/service_type/model/service_type.dart';
import 'account_permissions.dart';

/// Authenticated account info from `GET /accounts/me/`.
class AccountProfile {
  const AccountProfile({
    required this.fullName,
    required this.phone,
    required this.permissions,
  });

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    final fullName = _readFullName(json);
    final phone = _readString(json, const [
      'phone',
      'phoneNumber',
      'phone_number',
    ]);
    final permissions = _readPermissions(json);

    if (fullName == null || phone == null) {
      throw FormatException(
        'Missing fullName or phone in account profile response: $json',
      );
    }

    return AccountProfile(
      fullName: fullName,
      phone: phone,
      permissions: permissions,
    );
  }

  final String fullName;
  final String phone;
  final List<String> permissions;

  List<ServiceType> get assignedServiceTypes =>
      AccountPermissions.resolveServiceTypes(permissions);

  static String? _readFullName(Map<String, dynamic> json) {
    final direct = _readString(json, const ['fullName', 'full_name', 'name']);
    if (direct != null) return direct;

    final firstName = _readString(json, const ['firstName', 'first_name']);
    final lastName = _readString(json, const ['lastName', 'last_name']);
    final parts = [
      firstName,
      lastName,
    ].whereType<String>().where((value) => value.isNotEmpty);

    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  static List<String> _readPermissions(Map<String, dynamic> json) {
    final direct = json['permissions'];
    if (direct is List) {
      return _parsePermissionList(direct);
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return _readPermissions(data);
    }

    return const [];
  }

  static List<String> _parsePermissionList(List<dynamic> raw) {
    final permissions = <String>[];

    for (final item in raw) {
      if (item is String && item.isNotEmpty) {
        permissions.add(item);
        continue;
      }

      if (item is Map<String, dynamic>) {
        final code = item['code'] ??
            item['permission'] ??
            item['name'] ??
            item['slug'];
        if (code is String && code.isNotEmpty) {
          permissions.add(code);
        }
      }
    }

    return permissions;
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return _readString(data, keys);
    }

    return null;
  }
}
