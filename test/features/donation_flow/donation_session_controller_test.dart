import 'package:damla/core/constants/donation_rules.dart';
import 'package:damla/features/donation_flow/controller/donation_session_controller.dart';
import 'package:damla/features/donation_flow/models/donation_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DonationSessionController Testleri', () {
    late DonationSessionController controller;

    setUp(() {
      controller = DonationSessionController(targetMl: 450);
    });

    tearDown(() {
      controller.dispose();
    });

    test('1. Başlangıç durumu testleri', () {
      expect(controller.stage, DonationStage.eligibility);
      expect(controller.collectedMl, 0);
      expect(controller.targetMl, 450);
      expect(controller.isRunning, isFalse);

      // Pre aşamalarında fillRatio sakin başlangıç için 0.15 olmalıdır
      expect(controller.fillRatio, DonationRules.preDonationVisualRatio);
    });

    test('2. Tick sonrası toplanan ml ve fillRatio artışı', () {
      controller.transitionTo(DonationStage.preparation);
      controller.transitionTo(DonationStage.active);

      expect(controller.stage, DonationStage.active);
      expect(controller.isRunning, isTrue);

      controller.tick(const Duration(seconds: 12)); // 50 ml/dk ile 12 saniyede ~10 ml
      expect(controller.collectedMl, greaterThanOrEqualTo(8));
      expect(controller.fillRatio, greaterThan(0.01));
    });

    test('3. Hedefe ulaşınca closing ve completed aşamasına geçiş', () {
      controller.transitionTo(DonationStage.preparation);
      controller.transitionTo(DonationStage.active);

      controller.debugSetCollectedMl(445);
      expect(controller.stage, DonationStage.active);

      // 450 ml hedefine ulaşınca closing'e geçer
      controller.tick(const Duration(seconds: 10));
      expect(controller.collectedMl, 450);
      expect(controller.stage, DonationStage.closing);
      expect(controller.isRunning, isFalse);
    });

    test('4. fillRatio asla 1.0 değerini aşmamalıdır', () {
      controller.transitionTo(DonationStage.preparation);
      controller.transitionTo(DonationStage.active);

      controller.debugSetCollectedMl(450);
      expect(controller.fillRatio, 1.0);

      controller.debugSetCollectedMl(999);
      expect(controller.collectedMl, 450);
      expect(controller.fillRatio, lessThanOrEqualTo(1.0));
    });

    test('5. pauseDonation ve resetToEligibility fonksiyonları', () {
      controller.transitionTo(DonationStage.preparation);
      controller.transitionTo(DonationStage.active);
      controller.tick(const Duration(seconds: 6));
      expect(controller.collectedMl, greaterThan(0));

      controller.pauseDonation();
      expect(controller.stage, DonationStage.paused);
      expect(controller.isRunning, isFalse);

      controller.resumeDonation();
      expect(controller.stage, DonationStage.active);

      controller.resetToEligibility();
      expect(controller.stage, DonationStage.eligibility);
      expect(controller.collectedMl, 0);
      expect(controller.fillRatio, DonationRules.preDonationVisualRatio);
      expect(controller.isRunning, isFalse);
    });
  });
}
