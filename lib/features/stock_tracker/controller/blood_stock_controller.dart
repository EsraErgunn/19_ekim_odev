import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/blood_group_stock.dart';

enum StockFilter { all, criticalOnly }

/// Kan Grubu Stok Takip Controller'ı
class BloodStockController extends ChangeNotifier {
  BloodStockController({Random? random}) : _random = random ?? Random() {
    _initDefaultStocks();
  }

  final Random _random;
  StockFilter _filter = StockFilter.all;
  final List<BloodGroupStock> _stocks = [];

  StockFilter get filter => _filter;
  List<BloodGroupStock> get stocks => List.unmodifiable(_stocks);

  List<BloodGroupStock> get filteredStocks {
    if (_filter == StockFilter.criticalOnly) {
      return _stocks
          .where((s) => s.status == BloodStockStatus.critical || s.status == BloodStockStatus.low)
          .toList();
    }
    return List.unmodifiable(_stocks);
  }

  int get totalUnits => _stocks.fold(0, (sum, item) => sum + item.currentUnits);
  int get targetUnits => _stocks.fold(0, (sum, item) => sum + item.targetUnits);
  int get criticalGroupCount =>
      _stocks.where((s) => s.status == BloodStockStatus.critical).length;
  double get overallFillRatio => (totalUnits / targetUnits).clamp(0.0, 1.0);

  void setFilter(StockFilter filter) {
    if (_filter != filter) {
      _filter = filter;
      notifyListeners();
    }
  }

  void refreshStocksSimulated() {
    for (int i = 0; i < _stocks.length; i++) {
      final item = _stocks[i];
      final delta = _random.nextInt(7) - 3; // -3 ile +3 ünite arası simülasyon dalgalanması
      final newUnits = (item.currentUnits + delta).clamp(5, item.targetUnits);
      _stocks[i] = BloodGroupStock(
        bloodType: item.bloodType,
        currentUnits: newUnits,
        targetUnits: item.targetUnits,
        canDonateTo: item.canDonateTo,
        canReceiveFrom: item.canReceiveFrom,
        isRare: item.isRare,
      );
    }
    notifyListeners();
  }

  void _initDefaultStocks() {
    _stocks.addAll([
      const BloodGroupStock(
        bloodType: '0 Rh-',
        currentUnits: 28,
        targetUnits: 120,
        canDonateTo: ['Tüm Gruplara (Genel Verici)'],
        canReceiveFrom: ['0 Rh-'],
        isRare: true,
      ),
      const BloodGroupStock(
        bloodType: '0 Rh+',
        currentUnits: 82,
        targetUnits: 160,
        canDonateTo: ['0 Rh+', 'A Rh+', 'B Rh+', 'AB Rh+'],
        canReceiveFrom: ['0 Rh-', '0 Rh+'],
      ),
      const BloodGroupStock(
        bloodType: 'A Rh-',
        currentUnits: 34,
        targetUnits: 100,
        canDonateTo: ['A Rh-', 'A Rh+', 'AB Rh-', 'AB Rh+'],
        canReceiveFrom: ['0 Rh-', 'A Rh-'],
      ),
      const BloodGroupStock(
        bloodType: 'A Rh+',
        currentUnits: 135,
        targetUnits: 180,
        canDonateTo: ['A Rh+', 'AB Rh+'],
        canReceiveFrom: ['0 Rh-', '0 Rh+', 'A Rh-', 'A Rh+'],
      ),
      const BloodGroupStock(
        bloodType: 'B Rh-',
        currentUnits: 22,
        targetUnits: 90,
        canDonateTo: ['B Rh-', 'B Rh+', 'AB Rh-', 'AB Rh+'],
        canReceiveFrom: ['0 Rh-', 'B Rh-'],
        isRare: true,
      ),
      const BloodGroupStock(
        bloodType: 'B Rh+',
        currentUnits: 94,
        targetUnits: 140,
        canDonateTo: ['B Rh+', 'AB Rh+'],
        canReceiveFrom: ['0 Rh-', '0 Rh+', 'B Rh-', 'B Rh+'],
      ),
      const BloodGroupStock(
        bloodType: 'AB Rh-',
        currentUnits: 18,
        targetUnits: 70,
        canDonateTo: ['AB Rh-', 'AB Rh+'],
        canReceiveFrom: ['0 Rh-', 'A Rh-', 'B Rh-', 'AB Rh-'],
        isRare: true,
      ),
      const BloodGroupStock(
        bloodType: 'AB Rh+',
        currentUnits: 68,
        targetUnits: 80,
        canDonateTo: ['AB Rh+'],
        canReceiveFrom: ['Tüm Gruplardan (Genel Alıcı)'],
      ),
    ]);
  }
}
