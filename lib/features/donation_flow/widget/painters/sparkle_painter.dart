import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Tamamlanma (completed) aşamasında torba çevresinde parıldayan 4 köşeli yıldızları çizen CustomPainter.
class SparklePainter extends CustomPainter {
  SparklePainter({
    required this.animationValue,
    this.color = AppColors.gold,
  });

  /// 0.0 - 1.0 arası parıltı animasyon değeri
  final double animationValue;

  final Color color;

  // Torba etrafında estetik dağıtılmış yıldız koordinat oranları ve faz farkları
  static const List<_StarSpec> _stars = [
    _StarSpec(Offset(0.10, 0.22), size: 14.0, phase: 0.0),
    _StarSpec(Offset(0.88, 0.20), size: 16.0, phase: 1.2),
    _StarSpec(Offset(0.06, 0.56), size: 12.0, phase: 2.4),
    _StarSpec(Offset(0.92, 0.62), size: 15.0, phase: 3.6),
    _StarSpec(Offset(0.18, 0.82), size: 11.0, phase: 4.8),
    _StarSpec(Offset(0.84, 0.80), size: 13.0, phase: 0.8),
    _StarSpec(Offset(0.50, 0.06), size: 16.0, phase: 2.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final spec in _stars) {
      final center = Offset(
        size.width * spec.positionRatio.dx,
        size.height * spec.positionRatio.dy,
      );

      // Yanıp sönme ve nabız ölçeklemesi
      final twinkle =
          (math.sin((animationValue * 2 * math.pi) + spec.phase) + 1.0) / 2.0;
      final currentSize = spec.size * (0.45 + (0.55 * twinkle));
      final alpha = (0.3 + (0.7 * twinkle)).clamp(0.0, 1.0);

      paint.color = color.withValues(alpha: alpha);

      final starPath = _createFourPointedStar(center, currentSize);
      canvas.drawPath(starPath, paint);
    }
  }

  /// İçe kavisli 4 köşeli ikonik parıltı yıldızı yolu
  Path _createFourPointedStar(Offset center, double outerRadius) {
    final path = Path();
    path.moveTo(center.dx, center.dy - outerRadius);
    path.quadraticBezierTo(
        center.dx, center.dy, center.dx + outerRadius, center.dy);
    path.quadraticBezierTo(
        center.dx, center.dy, center.dx, center.dy + outerRadius);
    path.quadraticBezierTo(
        center.dx, center.dy, center.dx - outerRadius, center.dy);
    path.quadraticBezierTo(
        center.dx, center.dy, center.dx, center.dy - outerRadius);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}

class _StarSpec {
  const _StarSpec(this.positionRatio, {required this.size, required this.phase});

  final Offset positionRatio;
  final double size;
  final double phase;
}
