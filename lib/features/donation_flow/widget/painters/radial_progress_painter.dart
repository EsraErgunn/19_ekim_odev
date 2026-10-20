import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Torbanın etrafındaki dairesel ilerleme halkasını (gradient stroke) çizen CustomPainter.
class RadialProgressPainter extends CustomPainter {
  RadialProgressPainter({
    required this.progress,
    this.strokeWidth = 8.0,
    this.trackColor = AppColors.bloodRedTrack,
  });

  /// 0.0 - 1.0 arası ilerleme
  final double progress;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // 1. Arka plan iz halkası
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    // 2. Gradyanlı ilerleme yayı
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepGradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      transform: const GradientRotation(-math.pi / 2),
      colors: const [
        AppColors.bloodRedDark,
        AppColors.bloodRed,
        AppColors.bloodRedLight,
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final progressPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(RadialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor;
  }
}
