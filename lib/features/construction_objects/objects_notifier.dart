import 'package:flutter/foundation.dart';

import '../../entities/construction_object/model/access_status.dart';
import '../../entities/construction_object/model/construction_object.dart';
import '../../entities/construction_object/repository/object_repository.dart';

class ObjectsNotifier extends ChangeNotifier {
  ObjectsNotifier({ObjectRepository? repository})
      : _repository = repository ?? ObjectRepository.instance {
    _objects = _repository.localObjects;
    _load();
  }

  final ObjectRepository _repository;

  List<ConstructionObject> _objects = [];
  bool _isLoading = false;
  String? _error;

  List<ConstructionObject> get objects => _objects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _objects = await _repository.loadObjects();
    } catch (error, stackTrace) {
      debugPrint('Failed to load objects from JSONPlaceholder: $error');
      debugPrint('$stackTrace');
      _error = error.toString();
      _objects = _repository.localObjects;
    }

    _isLoading = false;
    notifyListeners();
  }

  ConstructionObject? findById(String id) {
    try {
      return _objects.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ConstructionObject> getAccessibleObjects() {
    return _objects.where((o) => o.accessStatus.isGranted).toList();
  }
}
