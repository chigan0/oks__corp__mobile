import '../../../entities/construction_object/model/access_status.dart';
import '../../../entities/construction_object/model/construction_object.dart';
import '../../../entities/construction_object/model/object_document.dart';
import '../../../entities/construction_object/model/object_status.dart';
import '../api/json_placeholder_user.dart';

class ConstructionObjectFromUserMapper {
  const ConstructionObjectFromUserMapper._();

  static const _meta = [
    (
      objectStatus: ObjectStatus.underConstruction,
      accessStatus: AccessStatus.granted,
      hasExpiry: true,
    ),
    (
      objectStatus: ObjectStatus.completed,
      accessStatus: AccessStatus.granted,
      hasExpiry: false,
    ),
    (
      objectStatus: ObjectStatus.underConstruction,
      accessStatus: AccessStatus.denied,
      hasExpiry: false,
    ),
  ];

  static ConstructionObject map(JsonPlaceholderUser user, {required int index}) {
    final meta = _meta[index % _meta.length];
    final objectId = 'obj-api-${user.id}';
    final name = _objectName(user);
    final address = _formatAddress(user.address);
    final issueDate = DateTime(2025, 9, 1 + index * 12, 10 + index);

    return ConstructionObject(
      id: objectId,
      name: name,
      address: address,
      objectStatus: meta.objectStatus,
      accessStatus: meta.accessStatus,
      issueDate: issueDate,
      accessExpiryDate: meta.hasExpiry ? DateTime(2026, 4, 15 + index * 10) : null,
      documents: [
        ObjectDocument(
          id: 'doc-api-${user.id}-1',
          fileName: 'tehnika_bezopasnosti.pdf',
          uploadedAt: DateTime(2026, 2, 10 + index, 11, 20),
        ),
        ObjectDocument(
          id: 'doc-api-${user.id}-2',
          fileName: '${_documentSlug(user.company.name)}.pdf',
          uploadedAt: DateTime(2026, 1, 5 + index, 9, 0),
        ),
      ],
      qrPayload: 'OKS|worker-001|$objectId|$name',
    );
  }

  static String _objectName(JsonPlaceholderUser user) {
    final company = user.company.name.trim();
    if (company.isNotEmpty) {
      return 'ЖК «${_cleanCompanyName(company)}»';
    }
    return user.name;
  }

  static String _cleanCompanyName(String company) {
    return company
        .replaceAll(RegExp(r'\b(LLC|Inc|Group|Corp)\b\.?', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _formatAddress(JsonPlaceholderAddress address) {
    final building = _extractBuildingNumber(address.suite);
    final street = address.street.trim();

    if (building != null) {
      return 'ул. $street, $building';
    }
    return 'ул. $street, ${address.city}';
  }

  static String? _extractBuildingNumber(String suite) {
    final match = RegExp(r'\d+').firstMatch(suite);
    return match?.group(0);
  }

  static String _documentSlug(String company) {
    final slug = company
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return slug.isEmpty ? 'project_docs' : '${slug}_docs';
  }
}
