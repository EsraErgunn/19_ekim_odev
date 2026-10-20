import 'package:flutter/foundation.dart';
import '../models/emergency_request.dart';

/// Acil Kan Talepleri Controller'ı
class EmergencyRequestsController extends ChangeNotifier {
  EmergencyRequestsController() {
    _initDefaultRequests();
  }

  final List<EmergencyBloodRequest> _requests = [];
  String _selectedBloodTypeFilter = 'Tümü';

  String get selectedBloodTypeFilter => _selectedBloodTypeFilter;
  List<EmergencyBloodRequest> get requests => List.unmodifiable(_requests);

  List<EmergencyBloodRequest> get filteredRequests {
    if (_selectedBloodTypeFilter == 'Tümü') {
      return List.unmodifiable(_requests);
    }
    return _requests.where((r) => r.bloodType == _selectedBloodTypeFilter).toList();
  }

  int get activeUrgentCount =>
      _requests.where((r) => !r.isFulfilled && r.urgency == RequestUrgency.critical).length;

  void setBloodTypeFilter(String filter) {
    if (_selectedBloodTypeFilter != filter) {
      _selectedBloodTypeFilter = filter;
      notifyListeners();
    }
  }

  bool supportRequest(String id) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index == -1) return false;

    final current = _requests[index];
    if (current.isFulfilled) return false;

    _requests[index] = current.copyWith(
      collectedUnits: current.collectedUnits + 1,
    );
    notifyListeners();
    return true;
  }

  void _initDefaultRequests() {
    _requests.addAll([
      EmergencyBloodRequest(
        id: 'req-001',
        hospitalName: 'Ankara Bilkent Şehir Hastanesi',
        city: 'Ankara',
        bloodType: '0 Rh-',
        patientInitials: 'M*** K*** (Çocuk Cerrahisi)',
        requiredUnits: 3,
        collectedUnits: 1,
        urgency: RequestUrgency.critical,
        diagnosis: 'Acil Kalp Cerrahisi Operasyonu',
        contactPhone: '444 7 000 (Dahili: 112)',
        createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      EmergencyBloodRequest(
        id: 'req-002',
        hospitalName: 'İstanbul Çapa Tıp Fakültesi',
        city: 'İstanbul',
        bloodType: 'A Rh-',
        patientInitials: 'E*** Y*** (Yoğun Bakım)',
        requiredUnits: 4,
        collectedUnits: 2,
        urgency: RequestUrgency.critical,
        diagnosis: 'Trafik Kazası Sonrası Politravma',
        contactPhone: '444 7 000 (Dahili: 118)',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      ),
      EmergencyBloodRequest(
        id: 'req-003',
        hospitalName: 'İzmir Ege Üniversitesi Hastanesi',
        city: 'İzmir',
        bloodType: 'B Rh-',
        patientInitials: 'A*** D*** (Hematoloji)',
        requiredUnits: 2,
        collectedUnits: 0,
        urgency: RequestUrgency.high,
        diagnosis: 'Akut Lösemi Trombosit Desteği',
        contactPhone: '444 7 000 (Dahili: 124)',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
      ),
      EmergencyBloodRequest(
        id: 'req-004',
        hospitalName: 'Antalya Şehir Hastanesi',
        city: 'Antalya',
        bloodType: 'AB Rh-',
        patientInitials: 'S*** T*** (Genel Cerrahi)',
        requiredUnits: 2,
        collectedUnits: 1,
        urgency: RequestUrgency.high,
        diagnosis: 'Karaciğer Nakil Hazırlığı',
        contactPhone: '444 7 000 (Dahili: 130)',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      EmergencyBloodRequest(
        id: 'req-005',
        hospitalName: 'Bursa Yüksek İhtisas Hastanesi',
        city: 'Bursa',
        bloodType: '0 Rh+',
        patientInitials: 'K*** B*** (Ortopedi)',
        requiredUnits: 3,
        collectedUnits: 2,
        urgency: RequestUrgency.normal,
        diagnosis: 'Planlı Kalça Protezi Cerrahisi',
        contactPhone: '444 7 000 (Dahili: 142)',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }
}
