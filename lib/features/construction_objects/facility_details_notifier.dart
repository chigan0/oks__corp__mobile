import 'package:flutter/foundation.dart';

import '../../entities/construction_object/model/facility_details.dart';
import '../../entities/construction_object/model/facility_document.dart';
import 'api/facilities_api.dart';

enum FacilityLoadStatus { loading, loaded, error }

/// Loads a single facility's full card (GET /facilities/{uuid}) and its
/// attached documents (GET /facilities/{uuid}/documents) independently, so a
/// failure in one request never hides data that the other already loaded.
class FacilityDetailsNotifier extends ChangeNotifier {
  FacilityDetailsNotifier({
    required FacilitiesApi api,
    required String facilityUuid,
  })  : _api = api,
        _facilityUuid = facilityUuid {
    loadDetails();
    loadDocuments();
  }

  final FacilitiesApi _api;
  final String _facilityUuid;

  FacilityLoadStatus _detailsStatus = FacilityLoadStatus.loading;
  FacilityDetails? _details;
  FacilitiesApiException? _detailsError;

  FacilityLoadStatus _documentsStatus = FacilityLoadStatus.loading;
  List<FacilityDocument> _documents = const [];
  FacilitiesApiException? _documentsError;

  FacilityLoadStatus get detailsStatus => _detailsStatus;
  FacilityDetails? get details => _details;
  FacilitiesApiException? get detailsError => _detailsError;

  FacilityLoadStatus get documentsStatus => _documentsStatus;
  List<FacilityDocument> get documents => _documents;
  FacilitiesApiException? get documentsError => _documentsError;

  Future<void> loadDetails() async {
    _detailsStatus = FacilityLoadStatus.loading;
    _detailsError = null;
    notifyListeners();

    try {
      _details = await _api.fetchFacilityDetails(_facilityUuid);
      _detailsStatus = FacilityLoadStatus.loaded;
    } on FacilitiesApiException catch (error) {
      _detailsError = error;
      _detailsStatus = FacilityLoadStatus.error;
    } catch (error) {
      _detailsError = const FacilitiesApiException(
        FacilitiesErrorType.unknown,
        'Не удалось загрузить данные объекта',
      );
      _detailsStatus = FacilityLoadStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadDocuments() async {
    _documentsStatus = FacilityLoadStatus.loading;
    _documentsError = null;
    notifyListeners();

    try {
      _documents = await _api.fetchFacilityDocuments(_facilityUuid);
      _documentsStatus = FacilityLoadStatus.loaded;
    } on FacilitiesApiException catch (error) {
      _documentsError = error;
      _documentsStatus = FacilityLoadStatus.error;
    } catch (error) {
      _documentsError = const FacilitiesApiException(
        FacilitiesErrorType.unknown,
        'Не удалось загрузить документы',
      );
      _documentsStatus = FacilityLoadStatus.error;
    }

    notifyListeners();
  }
}
