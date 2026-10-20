import '../../../core/constants/donation_rules.dart';

enum Gender {
  male,
  female;

  String get label => this == Gender.male ? 'Erkek' : 'Kadın';
}

/// Bağışçı uygunluk değerlendirme girdi verileri.
class EligibilityInput {
  const EligibilityInput({
    required this.age,
    required this.weightKg,
    required this.gender,
    this.lastDonationDate,
    this.hasChronicIllnessOrMeds = false,
    this.consumedAlcoholLast24Hours = false,
    this.recentPiercingOrSurgery = false,
  });

  final int age;
  final double weightKg;
  final Gender gender;
  final DateTime? lastDonationDate;
  final bool hasChronicIllnessOrMeds;
  final bool consumedAlcoholLast24Hours;
  final bool recentPiercingOrSurgery;

  EligibilityInput copyWith({
    int? age,
    double? weightKg,
    Gender? gender,
    DateTime? lastDonationDate,
    bool? hasChronicIllnessOrMeds,
    bool? consumedAlcoholLast24Hours,
    bool? recentPiercingOrSurgery,
  }) {
    return EligibilityInput(
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      hasChronicIllnessOrMeds:
          hasChronicIllnessOrMeds ?? this.hasChronicIllnessOrMeds,
      consumedAlcoholLast24Hours:
          consumedAlcoholLast24Hours ?? this.consumedAlcoholLast24Hours,
      recentPiercingOrSurgery:
          recentPiercingOrSurgery ?? this.recentPiercingOrSurgery,
    );
  }
}

/// Uygunluk değerlendirme sonucu.
class EligibilityResult {
  const EligibilityResult({
    required this.isEligible,
    this.rejectionReasons = const [],
    this.nextEligibleDate,
  });

  final bool isEligible;
  final List<String> rejectionReasons;
  final DateTime? nextEligibleDate;

  /// donation_rules.dart kurallarına göre bağışçı uygunluğunu denetler.
  static EligibilityResult evaluate(
    EligibilityInput input, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final reasons = <String>[];
    DateTime? nextDate;

    // 1. Yaş kontrolü (18-65)
    if (input.age < DonationRules.minAge) {
      reasons.add('Bağış için yaşınız en az ${DonationRules.minAge} olmalıdır.');
    } else if (input.age > DonationRules.maxAge) {
      reasons.add('Bağış için yaşınız en fazla ${DonationRules.maxAge} olabilir.');
    }

    // 2. Kilo kontrolü (>= 50 kg)
    if (input.weightKg < DonationRules.minWeightKg) {
      reasons.add(
        'Vücut ağırlığınız en az ${DonationRules.minWeightKg.toInt()} kg olmalıdır (Mevcut: ${input.weightKg.toInt()} kg).',
      );
    }

    // 3. Son bağış tarihi ve bekleme süresi
    if (input.lastDonationDate != null) {
      final intervalDays = input.gender == Gender.male
          ? DonationRules.maleIntervalDays
          : DonationRules.femaleIntervalDays;
      final requiredNext = input.lastDonationDate!.add(Duration(days: intervalDays));

      if (currentTime.isBefore(requiredNext)) {
        final daysLeft = requiredNext.difference(currentTime).inDays + 1;
        nextDate = requiredNext;
        reasons.add(
          '${input.gender.label} bağışçılar için zorunlu bekleme süresi $intervalDays gündür. '
          'Bağışa $daysLeft gün sonra uygun olacaksınız.',
        );
      }
    }

    // 4. Sağlık Soruları
    if (input.hasChronicIllnessOrMeds) {
      reasons.add('Düzenli ilaç kullanımı veya kronik rahatsızlık bağışa engel teşkil eder.');
    }

    if (input.consumedAlcoholLast24Hours) {
      reasons.add('Son 24 saat içinde alkol tüketimi bulunması bağışa engeldir.');
    }

    if (input.recentPiercingOrSurgery) {
      reasons.add('Son 12 ayda cerrahi işlem, dövme veya piercing yaptırılmış olması bekleme gerektirir.');
    }

    return EligibilityResult(
      isEligible: reasons.isEmpty,
      rejectionReasons: reasons,
      nextEligibleDate: nextDate,
    );
  }
}
