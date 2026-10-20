import 'package:flutter/foundation.dart';

/// Simülasyon hız seçenekleri (1x: Gerçek zaman, 10x: Hızlı, 60x: 1 dk = 1 sn)
enum SimulationSpeed {
  realTime1x(1.0, '1x (Gerçek Zaman)'),
  fast10x(10.0, '10x Hızlandırılmış'),
  ultraFast60x(60.0, '60x (1 sn = 1 dk)');

  const SimulationSpeed(this.multiplier, this.label);

  final double multiplier;
  final String label;
}

/// Tüm aşamaların simülasyon zamanı ölçeklemesini yöneten saat sınıfı.
class SimulationClock extends ChangeNotifier {
  SimulationClock({SimulationSpeed initialSpeed = SimulationSpeed.ultraFast60x})
      : _speed = initialSpeed;

  SimulationSpeed _speed;

  SimulationSpeed get speed => _speed;
  double get multiplier => _speed.multiplier;

  /// Hızı değiştirir ve dinleyicileri uyarır.
  void setSpeed(SimulationSpeed newSpeed) {
    if (_speed == newSpeed) return;
    _speed = newSpeed;
    notifyListeners();
  }

  /// Gerçek geçen süreyi simülasyon süresine dönüştürür.
  Duration toSimulationDuration(Duration realDuration) {
    final micro = (realDuration.inMicroseconds * multiplier).round();
    return Duration(microseconds: micro);
  }

  /// Simülasyon süresini gerçek bekleme süresine dönüştürür.
  Duration toRealDuration(Duration simulationDuration) {
    if (multiplier <= 0) return Duration.zero;
    final micro = (simulationDuration.inMicroseconds / multiplier).round();
    return Duration(microseconds: micro);
  }
}
