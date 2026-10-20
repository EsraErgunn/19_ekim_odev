import 'dart:ui' as ui;
import 'package:damla/features/donation_flow/controller/donation_session_controller.dart';
import 'package:damla/features/donation_flow/models/bag_geometry.dart';
import 'package:damla/features/donation_flow/models/donation_stage.dart';
import 'package:damla/features/donation_flow/view/donation_flow_page.dart';
import 'package:damla/features/donation_flow/widget/layered_blood_bag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ui.Image> createTestImage([int width = 50, int height = 50]) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = Colors.white,
  );
  final picture = recorder.endRecording();
  return picture.toImage(width, height);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LayeredBloodBag Widget Testleri', () {
    testWidgets('Görseller sağlandığında hatasız render edilir', (tester) async {
      final bag = await createTestImage(100, 100);
      final mask = await createTestImage(100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 250,
                child: LayeredBloodBag(
                  fillRatio: 0.50,
                  stage: DonationStage.active,
                  bagEmptyImage: bag,
                  maskImage: mask,
                  geometry: const BagGeometry(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LayeredBloodBag), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Completed aşamasında hatasız render edilir', (tester) async {
      final bag = await createTestImage(100, 100);
      final mask = await createTestImage(100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 250,
                child: LayeredBloodBag(
                  fillRatio: 1.0,
                  stage: DonationStage.completed,
                  bagEmptyImage: bag,
                  maskImage: mask,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LayeredBloodBag), findsOneWidget);
    });
  });

  group('DonationFlowPage Widget Testleri', () {
    testWidgets('Sayfa başlangıç durumu ve uygunluk formu etkileşimi', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = DonationSessionController();

      await tester.pumpWidget(
        MaterialApp(
          home: DonationFlowPage(controller: controller),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Başlangıç durumu: Uygunluk Testi
      expect(find.text('Uygunluk Testi'), findsOneWidget);
      expect(find.text('0 / 450 ml'), findsOneWidget);
      expect(find.text('%15'), findsOneWidget);
      expect(find.byKey(const Key('evaluate_button')), findsOneWidget);

      // Uygunluğu onayla ve hazırlığa geç
      await tester.tap(find.byKey(const Key('evaluate_button')));
      await tester.pump(const Duration(milliseconds: 100));

      // Preparation aşamasına geçilmeli
      expect(controller.stage, DonationStage.preparation);
      expect(find.text('Ön Hazırlık'), findsOneWidget);
      expect(find.byKey(const Key('start_countdown_button')), findsOneWidget);

      controller.dispose();
    });
  });
}
