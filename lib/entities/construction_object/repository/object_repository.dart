import '../../../features/construction_objects/api/json_placeholder_api.dart';
import '../../../features/construction_objects/mappers/construction_object_from_user_mapper.dart';
import '../model/access_status.dart';
import '../model/construction_object.dart';
import '../model/object_document.dart';
import '../model/object_status.dart';

/// Local mock data plus objects loaded from JSONPlaceholder.
class ObjectRepository {
  ObjectRepository._({JsonPlaceholderApi? api})
      : _api = api ?? JsonPlaceholderApi();

  static final ObjectRepository instance = ObjectRepository._();

  static const _apiUserIds = [5, 6, 7];

  final JsonPlaceholderApi _api;

  static final _documents = [
    ObjectDocument(
      id: 'doc-1',
      fileName: 'tehnika_bezopasnosti.pdf',
      uploadedAt: DateTime(2026, 3, 3, 12, 34),
    ),
    ObjectDocument(
      id: 'doc-2',
      fileName: 'instrukciya_po_tb.pdf',
      uploadedAt: DateTime(2026, 2, 15, 9, 20),
    ),
  ];

  final List<ConstructionObject> _localObjects = [
    ConstructionObject(
      id: 'obj-1',
      name: 'Kainar Village',
      address: 'ул. Адырбекова, 133',
      objectStatus: ObjectStatus.underConstruction,
      accessStatus: AccessStatus.granted,
      issueDate: DateTime(2025, 12, 21),
      accessExpiryDate: DateTime(2026, 3, 3),
      documents: _documents,
      qrPayload: 'OKS|worker-001|obj-1|Kainar Village',
    ),
    ConstructionObject(
      id: 'obj-2',
      name: 'Кодовое название',
      address: 'ул. Адырбекова, 133',
      objectStatus: ObjectStatus.completed,
      accessStatus: AccessStatus.denied,
      issueDate: DateTime(2025, 12, 21),
      documents: _documents,
      qrPayload: 'OKS|worker-001|obj-2|Кодовое название',
    ),
    ConstructionObject(
      id: 'obj-3',
      name: 'ЖК «Алатау»',
      address: 'пр. Абая, 45',
      objectStatus: ObjectStatus.underConstruction,
      accessStatus: AccessStatus.granted,
      issueDate: DateTime(2025, 11, 10),
      accessExpiryDate: DateTime(2026, 6, 30),
      documents: _documents,
      qrPayload: 'OKS|worker-001|obj-3|ЖК «Алатау»',
    ),
    ConstructionObject(
      id: 'obj-4',
      name: 'БЦ «Central Park»',
      address: 'ул. Кенесары, 88',
      objectStatus: ObjectStatus.underConstruction,
      accessStatus: AccessStatus.denied,
      issueDate: DateTime(2025, 10, 5),
      documents: _documents,
      qrPayload: 'OKS|worker-001|obj-4|БЦ «Central Park»',
    ),
  ];

  List<ConstructionObject> _apiObjects = [];
  List<ConstructionObject> _allObjects = [];
  bool _isLoaded = false;

  List<ConstructionObject> get localObjects => List.unmodifiable(_localObjects);

  List<ConstructionObject> get objects =>
      _isLoaded ? _allObjects : List.unmodifiable(_localObjects);

  bool get isLoaded => _isLoaded;

  Future<List<ConstructionObject>> loadObjects() async {
    if (_isLoaded) return _allObjects;

    final users = await _api.fetchUsersByIds(_apiUserIds);
    _apiObjects = [
      for (var i = 0; i < users.length; i++)
        ConstructionObjectFromUserMapper.map(users[i], index: i),
    ];

    _allObjects = [..._localObjects, ..._apiObjects];
    _isLoaded = true;
    return _allObjects;
  }

  ConstructionObject? findById(String id) {
    final list = _isLoaded ? _allObjects : _localObjects;
    try {
      return list.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ConstructionObject> getAccessibleObjects() {
    return objects.where((o) => o.accessStatus.isGranted).toList();
  }
}