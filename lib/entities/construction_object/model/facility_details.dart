import 'access_status.dart';
import 'object_status.dart';

/// Full facility card, as returned by GET /facilities/{uuid}.
class FacilityDetails {
  const FacilityDetails({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.status,
    required this.hasAccess,
    required this.plannedYear,
    required this.plannedQuarter,
    this.plannedStartYear,
    this.plannedStartQuarter,
    this.issuedAt,
  });

  final String id;
  final String code;
  final String name;
  final String address;
  final ObjectStatus status;
  final bool hasAccess;
  final int? plannedStartYear;
  final String? plannedStartQuarter;
  final int plannedYear;
  final String plannedQuarter;

  /// When access was granted; null when [hasAccess] is false.
  final DateTime? issuedAt;

  AccessStatus get accessStatus =>
      hasAccess ? AccessStatus.granted : AccessStatus.denied;

  factory FacilityDetails.fromJson(Map<String, dynamic> json) {
    return FacilityDetails(
      id: json['uuid'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: ObjectStatus.fromJson(json['status'] as String?),
      hasAccess: json['hasAccess'] as bool? ?? false,
      plannedStartYear: (json['plannedStartYear'] as num?)?.toInt(),
      plannedStartQuarter: json['plannedStartQuarter'] as String?,
      plannedYear: (json['plannedYear'] as num?)?.toInt() ?? 0,
      plannedQuarter: json['plannedQuarter'] as String? ?? '',
      issuedAt: switch (json['issuedAt']) {
        final String value => DateTime.tryParse(value),
        _ => null,
      },
    );
  }
}
