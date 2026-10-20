import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/bag_geometry.dart';

/// Aktif aşamada tüpün torbaya girdiği noktada sıçrayan kan damlacıklarını çizen CustomPainter.
class SplashPainter extends CustomPainter {
  SplashPainter({
    required this.progress,
    required this.geometry,
    this.color = AppColors.bloodRedLight,
    this.particleCount = 8,
  });

  /// 0.0 - 1.0 arası sürekli dönen animasyon ilerlemesi
  final double progress;

  /// Torba koordinat modeli (port noktası buradan alınır)
  final BagGeometry geometry;

  final Color color;
  final int particleCount;

  @override
  void paint(Canvas canvas, Size size) {
    final port = geometry.getPortOffset(size);
    final paint = Paint()..style = PaintingStyle.fill;

    // Sabit parametreli 8 damlacık partikülü (deterministik ve jank-free)
    for (int i = 0; i < particleCount; i++) {
      final t = (progress + (i / particleCount)) % 1.0;

      // Yatayda sağa ve sola hafif yayılma açısı (-135° ile -45° arası yukarı)
      final spread = -math.pi / 2 + ((i - (particleCount - 1) / 2) * 0.28);
      const baseVelocity = 38.0;
      final velocity = baseVelocity + ((i % 3) * 9.0);
      const gravity = 110.0;

      final dx = math.cos(spread) * velocity * t;
      final dy = math.sin(spread) * velocity * t + 0.5 * gravity * t * t;

      final alpha = (1.0 - t).clamp(0.0, 1.0);
      final radius = math.max(1.0, (2.6 - (t * 1.2)));

      paint.color = color.withValues(alpha: alpha * 0.9);
      canvas.drawCircle(Offset(port.dx + dx, port.dy + dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(SplashPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.geometry != geometry ||
        oldDelegate.color != color ||
        oldDelegate.particleCount != particleCount;
  }
}
