import 'package:damla/features/stock_tracker/controller/blood_stock_controller.dart';
import 'package:damla/features/stock_tracker/models/blood_group_stock.dart';
import 'package:damla/features/stock_tracker/view/blood_stock_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BloodGroupStock Model Testleri', () {
    test('Doluluk oranına göre doğru status belirlenmeli', () {
      const stockCrit = BloodGroupStock(
        bloodType: '0 Rh-',
        currentUnits: 20,
        targetUnits: 100,
        canDonateTo: ['Hepsi'],
        canReceiveFrom: ['0 Rh-'],
      );
      expect(stockCrit.fillRatio, 0.2);
      expect(stockCrit.status, BloodStockStatus.critical);

      const stockLow = BloodGroupStock(
        bloodType: 'A Rh-',
        currentUnits: 50,
        targetUnits: 100,
        canDonateTo: ['Hepsi'],
        canReceiveFrom: ['A Rh-'],
      );
      expect(stockLow.fillRatio, 0.5);
      expect(stockLow.status, BloodStockStatus.low);

      const stockOpt = BloodGroupStock(
        bloodType: 'A Rh+',
        currentUnits: 90,
        targetUnits: 100,
        canDonateTo: ['A Rh+'],
        canReceiveFrom: ['Hepsi'],
      );
      expect(stockOpt.fillRatio, 0.9);
      expect(stockOpt.status, BloodStockStatus.optimal);
    });
  });

  group('BloodStockController Testleri', () {
    test('Başlangıçta 8 kan grubu ve özet verileri doğru hesaplanmalı', () {
      final controller = BloodStockController();

      expect(controller.stocks.length, 8);
      expect(controller.totalUnits, greaterThan(0));
      expect(controller.targetUnits, greaterThan(0));
      expect(controller.criticalGroupCount, greaterThan(0));
      expect(controller.overallFillRatio, inInclusiveRange(0.0, 1.0));
    });

    test('Filtreleme criticalOnly seçildiğinde yalnızca kritik ve düşük gruplar gelmeli', () {
      final controller = BloodStockController();
      expect(controller.filter, StockFilter.all);

      controller.setFilter(StockFilter.criticalOnly);
      expect(controller.filter, StockFilter.criticalOnly);

      for (final stock in controller.filteredStocks) {
        expect(
          stock.status == BloodStockStatus.critical || stock.status == BloodStockStatus.low,
          isTrue,
        );
      }
    });

    test('refreshStocksSimulated notifyListeners tetiklemeli', () {
      final controller = BloodStockController();
      bool notified = false;
      controller.addListener(() => notified = true);

      controller.refreshStocksSimulated();
      expect(notified, isTrue);
    });
  });

  group('BloodStockPage Render Testi', () {
    testWidgets('BloodStockPage açılmalı ve başlık ile kartlar listelenmeli', (tester) async {
      final controller = BloodStockController();

      await tester.pumpWidget(
        MaterialApp(
          home: BloodStockPage(controller: controller),
        ),
      );
      await tester.pump();

      expect(find.text('Kan Grubu Stok Takibi'), findsOneWidget);
      expect(find.text('Ulusal Stok Durumu (Simülasyon)'), findsOneWidget);
      expect(find.text('0 Rh-'), findsOneWidget);
      expect(find.text('A Rh+'), findsOneWidget);
    });
  });
}
