import 'package:damla/features/emergency_requests/controller/emergency_requests_controller.dart';
import 'package:damla/features/emergency_requests/view/emergency_requests_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmergencyRequestsController Testleri', () {
    test('Başlangıç talepleri ve kritik sayı doğru gelmeli', () {
      final controller = EmergencyRequestsController();

      expect(controller.requests.isNotEmpty, isTrue);
      expect(controller.activeUrgentCount, greaterThan(0));
      expect(controller.selectedBloodTypeFilter, 'Tümü');
    });

    test('Kan grubu filtresi talepleri filtrelemeli', () {
      final controller = EmergencyRequestsController();

      controller.setBloodTypeFilter('0 Rh-');
      expect(controller.selectedBloodTypeFilter, '0 Rh-');

      for (final req in controller.filteredRequests) {
        expect(req.bloodType, '0 Rh-');
      }
    });

    test('supportRequest talebe ünite eklemeli ve tamamlandı durumuna getirebilmeli', () {
      final controller = EmergencyRequestsController();
      final target = controller.requests.first;
      final initialUnits = target.collectedUnits;

      final success = controller.supportRequest(target.id);
      expect(success, isTrue);

      final updated = controller.requests.firstWhere((r) => r.id == target.id);
      expect(updated.collectedUnits, initialUnits + 1);
    });
  });

  group('EmergencyRequestsPage Render Testi', () {
    testWidgets('EmergencyRequestsPage açılmalı ve başlık ile acil talepler listelenmeli', (tester) async {
      final controller = EmergencyRequestsController();

      await tester.pumpWidget(
        MaterialApp(
          home: EmergencyRequestsPage(controller: controller),
        ),
      );
      await tester.pump();

      expect(find.text('Acil Kan Talepleri'), findsOneWidget);
      expect(find.text('Kritik Seviye Çağrısı (Simülasyon)'), findsOneWidget);
      expect(find.text('Ankara Bilkent Şehir Hastanesi'), findsOneWidget);
      expect(find.text('Bağış Desteği Ver'), findsWidgets);
    });
  });
}
