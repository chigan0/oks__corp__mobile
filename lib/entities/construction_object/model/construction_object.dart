import 'access_status.dart';
import 'object_document.dart';
import 'object_status.dart';

class ConstructionObject {
  const ConstructionObject({
    required this.id,
    required this.name,
    required this.address,
    required this.objectStatus,
    required this.accessStatus,
    required this.issueDate,
    this.accessExpiryDate,
    required this.documents,
    required this.qrPayload,
  });

  final String id;
  final String name;
  final String address;
  final ObjectStatus objectStatus;
  final AccessStatus accessStatus;
  final DateTime issueDate;
  final DateTime? accessExpiryDate;
  final List<ObjectDocument> documents;
  final String qrPayload;
}
