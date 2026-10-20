import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../../core/constants/donation_rules.dart';
import '../data/donation_repository.dart';
import '../models/donation_record.dart';
import '../models/donation_stage.dart';
import '../models/eligibility_input.dart';
import 'simulation_clock.dart';

/// Akış hızı geçmişindeki tek bir zaman serisi noktası (fl_chart için).
class FlowRateSpot {
  const FlowRateSpot(this.simulationSecond, this.flowRateMlPerMin);
  final double simulationSecond;
  final double flowRateMlPerMin;
}

/// Kan bağışının tüm aşamalarını (eligibility -> completed) ve simülasyonunu yöneten controller.
class DonationSessionController extends ChangeNotifier {
  DonationSessionController({
    DonationRepository? repository,
    SimulationClock? clock,
    int? targetMl,
    math.Random? random,
  })  : _repository = repository ?? InMemoryDonationRepository(),
        clock = clock ?? SimulationClock(),
        targetMl = targetMl ?? DonationRules.standardUnitMl,
        _random = random ?? math.Random() {
    _stage = DonationStage.eligibility;
    _collectedMl = 0.0;
  }

  final DonationRepository _repository;
  final SimulationClock clock;
  final int targetMl;
  final math.Random _random;

  late DonationStage _stage;
  double _collectedMl = 0.0;
  Timer? _timer;

  // Uygunluk verileri
  EligibilityInput? _eligibilityInput;
  EligibilityResult? _eligibilityResult;

  // Hazırlık aşaması geri sayımı (3-2-1)
  int _preparationCountdown = 3;

  // Akış ve Top Sıkma Parametreleri
  bool _isSqueezing = false;
  double _secondsSinceLastSqueeze = 0.0;
  bool _needsSqueezeWarning = false;
  double _currentFlowRate = DonationRules.baseFlowRateMlPerMin;

  // Zaman takibi
  Duration _elapsedSimulationTime = Duration.zero;
  Duration _restingTimeRemaining = const Duration(minutes: DonationRules.restingDurationMinutes);
  final List<FlowRateSpot> _flowRateHistory = [];

  // Getters
  DonationStage get stage => _stage;
  int get collectedMl => _collectedMl.round();
  double get collectedMlPrecise => _collectedMl;
  bool get isRunning => _timer != null && _timer!.isActive;
  bool get isSqueezing => _isSqueezing;
  bool get needsSqueezeWarning => _needsSqueezeWarning;
  double get currentFlowRate => _currentFlowRate;
  Duration get elapsedSimulationTime => _elapsedSimulationTime;
  Duration get restingTimeRemaining => _restingTimeRemaining;
  int get preparationCountdown => _preparationCountdown;
  EligibilityInput? get eligibilityInput => _eligibilityInput;
  EligibilityResult? get eligibilityResult => _eligibilityResult;
  List<FlowRateSpot> get flowRateHistory => List.unmodifiable(_flowRateHistory);
  DonationRepository get repository => _repository;

  /// Sıvı seviyesi (0.0 - 1.0).
  /// eligibility ve preparation aşamalarında sakin görünüm (0.15) döner.
  double get fillRatio {
    if (_stage.isEligibility || _stage.isPreparation) {
      return DonationRules.preDonationVisualRatio;
    }
    if (targetMl <= 0) return 0.0;
    return (_collectedMl / targetMl).clamp(0.0, 1.0);
  }

  /// Kalan simülasyon süresi tahmini (son akış hızına göre).
  Duration get estimatedRemainingSimulationTime {
    if (_currentFlowRate <= 0.1 || _collectedMl >= targetMl) return Duration.zero;
    final remainingMl = targetMl - _collectedMl;
    final remainingMinutes = remainingMl / _currentFlowRate;
    return Duration(seconds: (remainingMinutes * 60).round());
  }

  // -------------------------------------------------------------------------
  // Durum Makinesi Geçişleri (State Machine Transitions)
  // -------------------------------------------------------------------------

  void transitionTo(DonationStage nextStage) {
    if (!_stage.canTransitionTo(nextStage)) {
      throw StateError(
        'Geçersiz aşama geçişi: $_stage -> $nextStage. '
        'İzin verilen geçişler: ${DonationStage.allowedTransitions[_stage]}',
      );
    }
    _stage = nextStage;
    _handleStageEnter(nextStage);
    notifyListeners();
  }

  void _handleStageEnter(DonationStage newStage) {
    switch (newStage) {
      case DonationStage.eligibility:
        _stopTimer();
        _collectedMl = 0.0;
        _flowRateHistory.clear();
        _elapsedSimulationTime = Duration.zero;
        break;
      case DonationStage.preparation:
        _preparationCountdown = 3;
        break;
      case DonationStage.active:
        _startSimulationTimer();
        break;
      case DonationStage.paused:
        _stopTimer();
        break;
      case DonationStage.closing:
        _stopTimer();
        _scheduleClosingTransition();
        break;
      case DonationStage.resting:
        _restingTimeRemaining = const Duration(minutes: DonationRules.restingDurationMinutes);
        _startRestingTimer();
        break;
      case DonationStage.completed:
        _stopTimer();
        _saveDonationRecord();
        break;
      case DonationStage.cancelled:
        _stopTimer();
        break;
    }
  }

  // -------------------------------------------------------------------------
  // 1. Aşama: Uygunluk Değerlendirmesi
  // -------------------------------------------------------------------------

  void submitEligibility(EligibilityInput input, {DateTime? now}) {
    _eligibilityInput = input;
    final result = EligibilityResult.evaluate(input, now: now);
    _eligibilityResult = result;

    if (result.isEligible && _stage == DonationStage.eligibility) {
      transitionTo(DonationStage.preparation);
    } else {
      notifyListeners();
    }
  }

  // -------------------------------------------------------------------------
  // 2. Aşama: Ön Hazırlık Geri Sayımı
  // -------------------------------------------------------------------------

  void decrementPreparationCountdown() {
    if (_stage != DonationStage.preparation) return;
    if (_preparationCountdown > 1) {
      _preparationCountdown--;
      notifyListeners();
    } else {
      _preparationCountdown = 0;
      transitionTo(DonationStage.active);
    }
  }

  // -------------------------------------------------------------------------
  // 3. Aşama: Aktif Akış ve Simülasyon Zamanı
  // -------------------------------------------------------------------------

  void setSqueezing(bool squeezing) {
    _isSqueezing = squeezing;
    if (squeezing) {
      _secondsSinceLastSqueeze = 0.0;
      _needsSqueezeWarning = false;
    }
    notifyListeners();
  }

  void _startSimulationTimer() {
    _stopTimer();
    const realTickMs = DonationRules.simulationTickMs;
    _timer = Timer.periodic(const Duration(milliseconds: realTickMs), (_) {
      final simDuration = clock.toSimulationDuration(const Duration(milliseconds: realTickMs));
      tick(simDuration);
    });
  }

  /// Tek bir simülasyon zaman adımı işletir (deterministik test edilebilir).
  void tick([Duration? simDelta]) {
    if (_stage != DonationStage.active) return;

    final delta = simDelta ?? clock.toSimulationDuration(
      const Duration(milliseconds: DonationRules.simulationTickMs),
    );
    final deltaSeconds = delta.inMicroseconds / 1000000.0;
    if (deltaSeconds <= 0) return;

    _elapsedSimulationTime += delta;

    // Top sıkma durumu ve uyarı hesabı
    if (_isSqueezing) {
      _secondsSinceLastSqueeze = 0.0;
      _needsSqueezeWarning = false;
    } else {
      _secondsSinceLastSqueeze += deltaSeconds;
      if (_secondsSinceLastSqueeze >= DonationRules.squeezeTimeoutSeconds) {
        _needsSqueezeWarning = true;
      }
    }

    // Çarpan hesabı
    double multiplier = 1.0;
    if (_isSqueezing) {
      multiplier = DonationRules.squeezeBoostMultiplier;
    } else if (_needsSqueezeWarning) {
      multiplier = DonationRules.slowFlowMultiplier;
    }

    // Dalgalanma (±%10 rastgele)
    final fluctuation = 1.0 + ((_random.nextDouble() * 2.0 - 1.0) * DonationRules.flowRateFluctuationRatio);
    _currentFlowRate = (DonationRules.baseFlowRateMlPerMin * multiplier * fluctuation).clamp(10.0, 90.0);

    // Toplanan kan artışı: rate (ml/dk) * deltaSeconds / 60
    final mlAdded = (_currentFlowRate * (deltaSeconds / 60.0));
    _collectedMl += mlAdded;

    // fl_chart için son 60 saniyelik geçmiş kaydı
    final currentSimSec = _elapsedSimulationTime.inSeconds.toDouble();
    _flowRateHistory.add(FlowRateSpot(currentSimSec, _currentFlowRate));
    while (_flowRateHistory.length > 60) {
      _flowRateHistory.removeAt(0);
    }

    // Hedefe ulaşıldı mı?
    if (_collectedMl >= targetMl) {
      _collectedMl = targetMl.toDouble();
      transitionTo(DonationStage.closing);
      return;
    }

    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // 4. Aşama: Closing (Klips Takılma)
  // -------------------------------------------------------------------------

  void _scheduleClosingTransition() {
    final realDuration = clock.toRealDuration(
      const Duration(seconds: DonationRules.closingDurationSeconds),
    );
    Timer(realDuration > const Duration(milliseconds: 100) ? realDuration : const Duration(milliseconds: 100), () {
      if (_stage == DonationStage.closing) {
        transitionTo(DonationStage.resting);
      }
    });
  }

  // -------------------------------------------------------------------------
  // 5. Aşama: Dinlenme (Resting)
  // -------------------------------------------------------------------------

  void _startRestingTimer() {
    _stopTimer();
    const realTickMs = 250;
    _timer = Timer.periodic(const Duration(milliseconds: realTickMs), (_) {
      final simDelta = clock.toSimulationDuration(const Duration(milliseconds: realTickMs));
      if (_restingTimeRemaining > simDelta) {
        _restingTimeRemaining -= simDelta;
        notifyListeners();
      } else {
        _restingTimeRemaining = Duration.zero;
        _stopTimer();
        transitionTo(DonationStage.completed);
      }
    });
  }

  // -------------------------------------------------------------------------
  // 6. Aşama: Tamamlanma ve Kayıt
  // -------------------------------------------------------------------------

  Future<void> _saveDonationRecord() async {
    final avgRate = _elapsedSimulationTime.inSeconds > 0
        ? (_collectedMl / (_elapsedSimulationTime.inSeconds / 60.0))
        : DonationRules.baseFlowRateMlPerMin;

    final record = DonationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      collectedMl: _collectedMl.round(),
      duration: _elapsedSimulationTime,
      averageFlowRate: double.parse(avgRate.toStringAsFixed(1)),
      pointsEarned: DonationRules.baseDonationPoints + DonationRules.onTimeBonusPoints,
    );

    await _repository.addDonation(record);
  }

  // -------------------------------------------------------------------------
  // Kontrol Eylemleri
  // -------------------------------------------------------------------------

  void pauseDonation() {
    if (_stage == DonationStage.active) {
      transitionTo(DonationStage.paused);
    }
  }

  void resumeDonation() {
    if (_stage == DonationStage.paused) {
      transitionTo(DonationStage.active);
    }
  }

  void cancelDonation() {
    if (_stage.canTransitionTo(DonationStage.cancelled)) {
      transitionTo(DonationStage.cancelled);
    }
  }

  void resetToEligibility() {
    _stopTimer();
    _collectedMl = 0.0;
    _flowRateHistory.clear();
    _elapsedSimulationTime = Duration.zero;
    _isSqueezing = false;
    _needsSqueezeWarning = false;
    _stage = DonationStage.eligibility;
    _handleStageEnter(DonationStage.eligibility);
    notifyListeners();
  }

  /// Test veya debug amaçlı doğrudan ml ayarlama
  void debugSetCollectedMl(double ml) {
    _collectedMl = ml.clamp(0.0, targetMl.toDouble());
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
