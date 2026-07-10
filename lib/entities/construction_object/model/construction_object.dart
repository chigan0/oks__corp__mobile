import 'access_status.dart';
import 'object_status.dart';

/// Facility list item, as returned by GET /facilities.
class ConstructionObject {
  const ConstructionObject({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.status,
    required this.hasAccess,
  });

  final String id;
  final String code;
  final String name;
  final String address;
  final ObjectStatus status;
  final bool hasAccess;

  AccessStatus get accessStatus =>
      hasAccess ? AccessStatus.granted : AccessStatus.denied;

  /// Kept as [ObjectStatus] for backward compatibility with existing UI.
  ObjectStatus get objectStatus => status;

  factory ConstructionObject.fromJson(Map<String, dynamic> json) {
    return ConstructionObject(
      id: json['uuid'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: ObjectStatus.fromJson(json['status'] as String?),
      hasAccess: json['hasAccess'] as bool? ?? false,
    );
  }
}
