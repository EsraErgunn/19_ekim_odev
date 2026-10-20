import 'package:damla/features/donation_flow/models/eligibility_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 20);

  group('Uygunluk (Eligibility) Değerlendirme Testleri', () {
    test('Tüm kriterleri sağlayan bağışçı uygun olmalı', () {
      final input = EligibilityInput(
        age: 28,
        weightKg: 68.0,
        gender: Gender.male,
        lastDonationDate: now.subtract(const Duration(days: 95)),
      );

      final result = EligibilityResult.evaluate(input, now: now);
      expect(result.isEligible, isTrue);
      expect(result.rejectionReasons, isEmpty);
    });

    test('Yaş sınırları (18 altı ve 65 üstü) reddedilmeli', () {
      final tooYoung = EligibilityInput(
        age: 17,
        weightKg: 65,
        gender: Gender.male,
      );
      final resYoung = EligibilityResult.evaluate(tooYoung, now: now);
      expect(resYoung.isEligible, isFalse);
      expect(resYoung.rejectionReasons.any((r) => r.contains('en az 18')), isTrue);

      final tooOld = EligibilityInput(
        age: 66,
        weightKg: 65,
        gender: Gender.female,
      );
      final resOld = EligibilityResult.evaluate(tooOld, now: now);
      expect(resOld.isEligible, isFalse);
      expect(resOld.rejectionReasons.any((r) => r.contains('en fazla 65')), isTrue);
    });

    test('Kilo sınırı (50 kg altı) reddedilmeli', () {
      final underWeight = EligibilityInput(
        age: 24,
        weightKg: 48.5,
        gender: Gender.female,
      );
      final result = EligibilityResult.evaluate(underWeight, now: now);
      expect(result.isEligible, isFalse);
      expect(result.rejectionReasons.any((r) => r.contains('50 kg')), isTrue);
    });

    test('Erkek bağışçılar için 90 gün kuralı', () {
      // 80 gün önce bağış yapmış erkek (10 gün beklemesi gerek)
      final inputRecent = EligibilityInput(
        age: 30,
        weightKg: 75,
        gender: Gender.male,
        lastDonationDate: now.subtract(const Duration(days: 80)),
      );
      final resRecent = EligibilityResult.evaluate(inputRecent, now: now);
      expect(resRecent.isEligible, isFalse);
      expect(resRecent.nextEligibleDate, isNotNull);

      // 90 gün önce bağış yapmış erkek (uygun)
      final inputValid = EligibilityInput(
        age: 30,
        weightKg: 75,
        gender: Gender.male,
        lastDonationDate: now.subtract(const Duration(days: 90)),
      );
      final resValid = EligibilityResult.evaluate(inputValid, now: now);
      expect(resValid.isEligible, isTrue);
    });

    test('Kadın bağışçılar için 120 gün kuralı', () {
      // 100 gün önce bağış yapmış kadın (20 gün beklemesi gerek)
      final inputRecent = EligibilityInput(
        age: 26,
        weightKg: 58,
        gender: Gender.female,
        lastDonationDate: now.subtract(const Duration(days: 100)),
      );
      final resRecent = EligibilityResult.evaluate(inputRecent, now: now);
      expect(resRecent.isEligible, isFalse);

      // 120 gün önce bağış yapmış kadın (uygun)
      final inputValid = EligibilityInput(
        age: 26,
        weightKg: 58,
        gender: Gender.female,
        lastDonationDate: now.subtract(const Duration(days: 120)),
      );
      final resValid = EligibilityResult.evaluate(inputValid, now: now);
      expect(resValid.isEligible, isTrue);
    });

    test('Sağlık anket soruları olumsuz ise reddedilmeli', () {
      final input = EligibilityInput(
        age: 25,
        weightKg: 60,
        gender: Gender.male,
        hasChronicIllnessOrMeds: true,
        consumedAlcoholLast24Hours: true,
        recentPiercingOrSurgery: true,
      );

      final result = EligibilityResult.evaluate(input, now: now);
      expect(result.isEligible, isFalse);
      expect(result.rejectionReasons.length, 3);
    });
  });
}
