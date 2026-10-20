import 'dart:math' as math;
import 'package:damla/features/donation_flow/controller/donation_session_controller.dart';
import 'package:damla/features/donation_flow/controller/simulation_clock.dart';
import 'package:damla/features/donation_flow/data/donation_repository.dart';
import 'package:damla/features/donation_flow/models/donation_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Durum Makinesi (State Machine) Testleri', () {
    late DonationSessionController controller;

    setUp(() {
      controller = DonationSessionController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Geçerli ardışık aşama geçişleri başarılı olmalı', () {
      expect(controller.stage, DonationStage.eligibility);

      // eligibility -> preparation
      controller.transitionTo(DonationStage.preparation);
      expect(controller.stage, DonationStage.preparation);

      // preparation -> active
      controller.transitionTo(DonationStage.active);
      expect(controller.stage, DonationStage.active);

      // active -> paused -> active
      controller.transitionTo(DonationStage.paused);
      expect(controller.stage, DonationStage.paused);
      controller.transitionTo(DonationStage.active);
      expect(controller.stage, DonationStage.active);

      // active -> closing -> resting -> completed
      controller.transitionTo(DonationStage.closing);
      expect(controller.stage, DonationStage.closing);

      controller.transitionTo(DonationStage.resting);
      expect(controller.stage, DonationStage.resting);

      controller.transitionTo(DonationStage.completed);
      expect(controller.stage, DonationStage.completed);

      // completed -> eligibility
      controller.transitionTo(DonationStage.eligibility);
      expect(controller.stage, DonationStage.eligibility);
    });

    test('Geçersiz aşama geçişinde StateError fırlatılmalı', () {
      expect(controller.stage, DonationStage.eligibility);

      // eligibility'den doğrudan active veya completed'a geçilemez
      expect(
        () => controller.transitionTo(DonationStage.active),
        throwsA(isA<StateError>()),
      );
      expect(
        () => controller.transitionTo(DonationStage.completed),
        throwsA(isA<StateError>()),
      );

      // preparation'a geçelim
      controller.transitionTo(DonationStage.preparation);

      // preparation'dan doğrudan resting veya completed'a geçilemez
      expect(
        () => controller.transitionTo(DonationStage.resting),
        throwsA(isA<StateError>()),
      );
    });

    test('İptal geçişleri ve başa dönüş', () {
      controller.transitionTo(DonationStage.preparation);
      controller.transitionTo(DonationStage.active);
      controller.cancelDonation();
      expect(controller.stage, DonationStage.cancelled);

      controller.resetToEligibility();
      expect(controller.stage, DonationStage.eligibility);
    });
  });

  group('SimulationClock Ölçek Testleri', () {
    test('60x hız ölçek doğruluğu (1 sn gerçek zaman = 60 sn simülasyon)', () {
      final clock = SimulationClock(initialSpeed: SimulationSpeed.ultraFast60x);
      expect(clock.multiplier, 60.0);

      // 1 saniyelik gerçek süre -> 60 saniyelik simülasyon süresi
      final simDuration = clock.toSimulationDuration(const Duration(seconds: 1));
      expect(simDuration.inSeconds, 60);

      // 10 dakikalık simülasyon dinlenme süresi -> 10 saniyelik gerçek bekleme
      final realDuration = clock.toRealDuration(const Duration(minutes: 10));
      expect(realDuration.inSeconds, 10);
    });

    test('10x ve 1x hız ölçekleri', () {
      final clock = SimulationClock(initialSpeed: SimulationSpeed.fast10x);
      expect(clock.toSimulationDuration(const Duration(seconds: 2)).inSeconds, 20);

      clock.setSpeed(SimulationSpeed.realTime1x);
      expect(clock.toSimulationDuration(const Duration(seconds: 5)).inSeconds, 5);
    });
  });

  group('Akış Hızı, Sıkma Çarpanı ve Simülasyon Testleri', () {
    test('Deterministik Random ile akış ve sıkma çarpanı (x1.2)', () {
      // Deterministik seed 42
      final controller = DonationSessionController(
        random: math.Random(42),
      );
      controller.transitionTo(DonationStage.preparation);
      controller.transitionTo(DonationStage.active);

      // Normal tick: taban 50 ml/dk civarında
      controller.tick(const Duration(seconds: 1));
      expect(controller.currentFlowRate, closeTo(50.0, 6.0));

      // Sıkma butonu aktif: x1.2 çarpanı ile ~60 ml/dk civarına yükselmeli
      controller.setSqueezing(true);
      controller.tick(const Duration(seconds: 1));
      expect(controller.currentFlowRate, greaterThan(55.0));

      controller.dispose();
    });

    test('20 saniye sıkılmazsa yavaşlama (x0.7) ve uyarı tetiklenmeli', () {
      final controller = DonationSessionController(
        random: math.Random(10),
      );
      controller.transitionTo(DonationStage.preparation);
      controller.transitionTo(DonationStage.active);

      expect(controller.needsSqueezeWarning, isFalse);

      // 21 saniye boyunca top sıkılmadan geçen simülasyon süresi
      controller.tick(const Duration(seconds: 21));
      expect(controller.needsSqueezeWarning, isTrue);
      // Hız ~35 ml/dk civarına (50 * 0.7) düşmeli
      expect(controller.currentFlowRate, lessThan(42.0));

      // Kullanıcı topu sıkınca uyarı sıfırlanmalı
      controller.setSqueezing(true);
      expect(controller.needsSqueezeWarning, isFalse);

      controller.dispose();
    });

    test('Hedef 450 ml toplanınca otomatik closing aşamasına geçilmeli', () {
      final controller = DonationSessionController();
      controller.transitionTo(DonationStage.preparation);
      controller.transitionTo(DonationStage.active);

      // 440 ml'ye yaklaştır
      controller.debugSetCollectedMl(440);

      // Büyük bir delta ile 450 ml sınırını aş
      controller.tick(const Duration(minutes: 1));
      expect(controller.collectedMl, 450);
      expect(controller.stage, DonationStage.closing);

      controller.dispose();
    });
  });

  group('DonationRepository ve Completed Kayıt Testleri', () {
    test('Completed aşamasına geçildiğinde repository kayıt eklemeli', () async {
      final repo = InMemoryDonationRepository();
      final controller = DonationSessionController(repository: repo);

      controller.transitionTo(DonationStage.preparation);
      controller.transitionTo(DonationStage.active);
      controller.debugSetCollectedMl(450);
      controller.transitionTo(DonationStage.closing);
      controller.transitionTo(DonationStage.resting);
      controller.transitionTo(DonationStage.completed);

      // Async kayıt eklenmesini bekle
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final donations = await repo.getDonations();
      expect(donations.length, 1);
      expect(donations.first.collectedMl, 450);
      expect(donations.first.pointsEarned, 150);

      controller.dispose();
    });
  });
}
