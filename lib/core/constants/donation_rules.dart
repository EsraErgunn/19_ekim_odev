/// Kan bağışı kuralları ve tıbbi/yasal parametreler için tek kaynak.
/// Sayılar kod içine dağıtılmaz, buradan okunur.
class DonationRules {
  const DonationRules._();

  /// Standart tam kan bağışı torba hacmi (ml).
  static const int standardUnitMl = 450;

  /// Ön hazırlık (pre-donation) aşamasındaki görsel sakin doluluk oranı.
  static const double preDonationVisualRatio = 0.15;

  /// Bağışçı yaş alt sınırı.
  static const int minAge = 18;

  /// Bağışçı yaş üst sınırı.
  static const int maxAge = 65;

  /// Minimum vücut ağırlığı (kg).
  static const double minWeightKg = 50.0;

  /// Erkek bağışçılar için iki bağış arası minimum bekleme süresi (gün).
  static const int maleIntervalDays = 90;

  /// Kadın bağışçılar için iki bağış arası minimum bekleme süresi (gün).
  static const int femaleIntervalDays = 120;

  /// Erkek bağışçılar için yıllık maksimum bağış sayısı.
  static const int maleMaxDonationsPerYear = 4;

  /// Kadın bağışçılar için yıllık maksimum bağış sayısı.
  static const int femaleMaxDonationsPerYear = 3;

  /// Bir ünite kan bağışının tahmini hayat kurtarma çarpanı (kişi).
  static const int livesSavedPerUnit = 3;

  /// Temel akış hızı (ml / simülasyon dakikası).
  static const double baseFlowRateMlPerMin = 50.0;

  /// Her tick'teki rastgele akış dalgalanma oranı (±%10).
  static const double flowRateFluctuationRatio = 0.10;

  /// "Topu sık" butonu basılı tutulurken akış hız çarpanı.
  static const double squeezeBoostMultiplier = 1.20;

  /// Sıkılmadığında akışın yavaşladığı hız çarpanı.
  static const double slowFlowMultiplier = 0.70;

  /// Top sıkılmadan geçebilecek maksimum simülasyon süresi (saniye).
  static const int squeezeTimeoutSeconds = 20;

  /// Klips takılma animasyon süresi (saniye).
  static const int closingDurationSeconds = 2;

  /// Bağış sonrası zorunlu dinlenme süresi (dakika).
  static const int restingDurationMinutes = 10;

  /// Başarılı bağışta kazanılan temel puan.
  static const int baseDonationPoints = 100;

  /// Zamanında bağış bonus puanı.
  static const int onTimeBonusPoints = 50;

  /// Simülasyon modu saat tick aralığı (milisaniye).
  static const int simulationTickMs = 200;

  /// Simülasyon modunda adım ml.
  static const int simulationStepMl = 15;
}
