/// Kan bağışı oturumunun durum makinesi aşamaları.
/// eligibility → preparation → active → closing → resting → completed (+ paused, cancelled)
enum DonationStage {
  /// 1. Uygunluk kontrolü (yaş, kilo, sağlık anketi)
  eligibility,

  /// 2. Ön hazırlık (turnike, dezenfeksiyon, 3-2-1 geri sayım)
  preparation,

  /// 3. Aktif bağış akışı (sıvı dolumu, top sıkma, anlık grafik)
  active,

  /// 4. Akış duraklatıldı
  paused,

  /// 5. Klips takılma ve tüp mühürleme (2 sn animasyon)
  closing,

  /// 6. Dinlenme aşaması (10 dk sayaç + bakım ipuçları)
  resting,

  /// 7. Tamamlandı ve kutlama (özet kartı, puanlar)
  completed,

  /// İptal edildi
  cancelled;

  bool get isEligibility => this == DonationStage.eligibility;
  bool get isPreparation => this == DonationStage.preparation;
  bool get isActive => this == DonationStage.active;
  bool get isPaused => this == DonationStage.paused;
  bool get isClosing => this == DonationStage.closing;
  bool get isResting => this == DonationStage.resting;
  bool get isCompleted => this == DonationStage.completed;
  bool get isCancelled => this == DonationStage.cancelled;

  /// Geriye uyumluluk için: preparation ve eligibility öncesi
  bool get isPre => isEligibility || isPreparation;

  /// Durum makinesinin izin verdiği geçiş haritası.
  static const Map<DonationStage, Set<DonationStage>> allowedTransitions = {
    DonationStage.eligibility: {DonationStage.preparation, DonationStage.cancelled},
    DonationStage.preparation: {DonationStage.active, DonationStage.cancelled},
    DonationStage.active: {DonationStage.closing, DonationStage.paused, DonationStage.cancelled},
    DonationStage.paused: {DonationStage.active, DonationStage.cancelled},
    DonationStage.closing: {DonationStage.resting, DonationStage.cancelled},
    DonationStage.resting: {DonationStage.completed, DonationStage.cancelled},
    DonationStage.completed: {DonationStage.eligibility},
    DonationStage.cancelled: {DonationStage.eligibility},
  };

  /// Hedef aşamaya geçişin kurallara uygun olup olmadığını denetler.
  bool canTransitionTo(DonationStage next) {
    return allowedTransitions[this]?.contains(next) ?? false;
  }

  String get label {
    switch (this) {
      case DonationStage.eligibility:
        return 'Uygunluk Testi';
      case DonationStage.preparation:
        return 'Ön Hazırlık';
      case DonationStage.active:
        return 'Bağış Sürüyor';
      case DonationStage.paused:
        return 'Duraklatıldı';
      case DonationStage.closing:
        return 'Mühürleniyor';
      case DonationStage.resting:
        return 'Dinlenme';
      case DonationStage.completed:
        return 'Tamamlandı';
      case DonationStage.cancelled:
        return 'İptal Edildi';
    }
  }

  String get description {
    switch (this) {
      case DonationStage.eligibility:
        return 'Bağış kriterlerine uygunluğunuz değerlendiriliyor.';
      case DonationStage.preparation:
        return 'Turnike ve iğne hazırlandı, akış başlamak üzere.';
      case DonationStage.active:
        return 'Kan torbaya akıyor, lütfen kolunuzu sabit tutun.';
      case DonationStage.paused:
        return 'Akış geçici olarak duraklatıldı.';
      case DonationStage.closing:
        return 'Bağış tamamlandı, torba klipsi takılıyor.';
      case DonationStage.resting:
        return 'Lütfen sedyeden kalkmayıp 10 dakika dinlenin.';
      case DonationStage.completed:
        return 'Tebrikler! 1 ünite bağışla 3 cana umut oldunuz.';
      case DonationStage.cancelled:
        return 'Bağış işlemi iptal edildi.';
    }
  }
}
