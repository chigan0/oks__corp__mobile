import 'package:flutter/foundation.dart';

import '../../entities/construction_object/model/construction_object.dart';
import 'api/facilities_api.dart';

class ObjectsNotifier extends ChangeNotifier {
  ObjectsNotifier({required FacilitiesApi api}) : _api = api {
    _load();
  }

  final FacilitiesApi _api;

  List<ConstructionObject> _objects = [];
  bool _isLoading = true;
  String? _error;

  List<ConstructionObject> get objects => _objects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _load() => reload();

  Future<void> reload() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _objects = await _api.fetchFacilities();
    } catch (error, stackTrace) {
      debugPrint('Failed to load facilities: $error');
      debugPrint('$stackTrace');
      _error = error.toString();
      _objects = [];
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
    return _objects.where((o) => o.hasAccess).toList();
  }
}
