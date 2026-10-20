import 'package:damla/features/donation_flow/controller/donation_session_controller.dart';
import 'package:damla/features/donation_flow/models/donation_stage.dart';
import 'package:damla/features/donation_flow/view/donation_flow_page.dart';
import 'package:damla/features/donation_flow/widget/donation_summary_card.dart';
import 'package:damla/features/donation_flow/widget/eligibility_form.dart';
import 'package:damla/features/donation_flow/widget/flow_rate_chart.dart';
import 'package:damla/features/donation_flow/widget/preparation_steps.dart';
import 'package:damla/features/donation_flow/widget/resting_timer.dart';
import 'package:damla/features/donation_flow/widget/squeeze_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Her Aşama Alt View Render Testleri', () {
    testWidgets('EligibilityForm sorunsuz render edilmeli', (tester) async {
      final controller = DonationSessionController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: EligibilityForm(controller: controller))),
      );
      expect(find.byType(EligibilityForm), findsOneWidget);
      expect(find.text('Bağışçı Uygunluk Kontrolü'), findsOneWidget);
    });

    testWidgets('EligibilityForm dar ekranda (320px) taşma yapmadan kadın ve erkek seçeneklerini göstermeli', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = DonationSessionController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SingleChildScrollView(child: EligibilityForm(controller: controller)))),
      );
      expect(find.text('Erkek (90 gün)'), findsOneWidget);
      expect(find.text('Kadın (120 gün)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PreparationSteps sorunsuz render edilmeli', (tester) async {
      final controller = DonationSessionController();
      controller.transitionTo(DonationStage.preparation);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PreparationSteps(controller: controller))),
      );
      expect(find.byType(PreparationSteps), findsOneWidget);
      expect(find.text('Turnike Bağlama'), findsOneWidget);
    });

    testWidgets('SqueezeButton sorunsuz render edilmeli', (tester) async {
      final controller = DonationSessionController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SqueezeButton(controller: controller))),
      );
      expect(find.byType(SqueezeButton), findsOneWidget);
      expect(find.text('Topu Sık (Basılı Tut)'), findsOneWidget);
    });

    testWidgets('FlowRateChart sorunsuz render edilmeli', (tester) async {
      final controller = DonationSessionController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FlowRateChart(controller: controller))),
      );
      expect(find.byType(FlowRateChart), findsOneWidget);
    });

    testWidgets('RestingTimer sorunsuz render edilmeli', (tester) async {
      final controller = DonationSessionController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RestingTimer(controller: controller))),
      );
      expect(find.byType(RestingTimer), findsOneWidget);
      expect(find.text('Zorunlu Dinlenme Süreci (Simülasyon)'), findsOneWidget);
    });

    testWidgets('DonationSummaryCard sorunsuz render edilmeli', (tester) async {
      final controller = DonationSessionController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: DonationSummaryCard(controller: controller))),
      );
      expect(find.byType(DonationSummaryCard), findsOneWidget);
      expect(find.text('Bağış Başarıyla Tamamlandı!'), findsOneWidget);
    });
  });

  group('DonationFlowPage Tüm Aşamalar Entegrasyon Testi', () {
    testWidgets('Aşamalara göre sayfa doğru alt viewları sunmalı', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = DonationSessionController();

      await tester.pumpWidget(
        MaterialApp(home: DonationFlowPage(controller: controller)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Eligibility
      expect(find.byType(EligibilityForm), findsOneWidget);

      // 2. Preparation
      controller.transitionTo(DonationStage.preparation);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PreparationSteps), findsOneWidget);

      // 3. Active
      controller.transitionTo(DonationStage.active);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(FlowRateChart), findsOneWidget);
      expect(find.byType(SqueezeButton), findsOneWidget);

      // 4. Resting
      controller.transitionTo(DonationStage.closing);
      controller.transitionTo(DonationStage.resting);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(RestingTimer), findsOneWidget);

      // 5. Completed
      controller.transitionTo(DonationStage.completed);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DonationSummaryCard), findsOneWidget);

      controller.dispose();
    });
  });
}
