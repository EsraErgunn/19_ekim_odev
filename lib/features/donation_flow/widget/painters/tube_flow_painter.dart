import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/bag_geometry.dart';

/// Ekran kenarından başlayıp üst porta uzanan 3 katmanlı gerçekçi silikon tüpü ve iç akışını çizen CustomPainter.
class TubeFlowPainter extends CustomPainter {
  TubeFlowPainter({
    required this.geometry,
    required this.isActive,
    required this.flowOffset,
    this.isCompleted = false,
    this.tubeWidth = 11.5,
    this.bloodWidth = 5.2,
  });

  /// Torba ve tüp koordinat modeli
  final BagGeometry geometry;

  /// Aktif akış durumu (tüp dolu ve kabarcıklar akar)
  final bool isActive;

  /// Akış ve kabarcık ilerleme değeri (0.0 - 1.0)
  final double flowOffset;

  /// Tamamlanma durumu (tüp mühürlü dolu kalır)
  final bool isCompleted;

  final double tubeWidth;
  final double bloodWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final tubePath = geometry.getTubePath(size);
    final metrics = tubePath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    // 1. Dış Katman (a): Kalın, yarı saydam açık gri plastik ve 3D sınır konturu
    final borderPaint = Paint()
      ..color = const Color(0x2294A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = tubeWidth + 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(tubePath, borderPaint);

    final outerSiliconePaint = Paint()
      ..color = const Color(0x38E2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = tubeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(tubePath, outerSiliconePaint);

    // 2. İç Katman (b): Sıvı rengi, yalnızca dolu kısımda (PathMetric.extractPath ile)
    final isFilled = isActive || isCompleted;
    if (isFilled) {
      final filledPath = metric.extractPath(0.0, metric.length);
      final bloodPaint = Paint()
        ..color = AppColors.bloodRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = bloodWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(filledPath, bloodPaint);

      // Aktif aşamada tüp içinde akan küçük açık renkli kabarcıklar
      if (isActive) {
        _drawTubeBubbles(canvas, metric);
      }
    }

    // 3. Üst Katman (c): İnce beyaz parlama çizgisi, hafif ofsetli
    canvas.save();
    canvas.translate(-1.0, -1.0);
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(tubePath, highlightPaint);
    canvas.restore();

    // 4. Debug geometrisi bindirmesi
    if (geometry.showGeometryOverlay) {
      _paintDebugOverlay(canvas, size, tubePath);
    }
  }

  void _drawTubeBubbles(Canvas canvas, PathMetric metric) {
    final bubblePaint = Paint()..style = PaintingStyle.fill;
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;

    const bubbleCount = 4;
    for (int i = 0; i < bubbleCount; i++) {
      final t = ((flowOffset + (i / bubbleCount)) % 1.0);
      final distance = t * metric.length;
      final tangent = metric.getTangentForOffset(distance);

      if (tangent != null) {
        final pos = tangent.position;
        bubblePaint.color = AppColors.bloodRedLight.withValues(alpha: 0.88);
        canvas.drawCircle(pos, 2.1, bubblePaint);
        canvas.drawCircle(Offset(pos.dx - 0.5, pos.dy - 0.5), 0.8, highlightPaint);
      }
    }
  }

  void _paintDebugOverlay(Canvas canvas, Size size, Path tubePath) {
    final innerRRect = geometry.getInnerRRect(size);

    final rectPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(innerRRect, rectPaint);

    final pathPaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(tubePath, pathPaint);

    final dotPaint = Paint()..style = PaintingStyle.fill;
    dotPaint.color = Colors.greenAccent;
    canvas.drawCircle(geometry.getPortOffset(size), 5, dotPaint);

    dotPaint.color = Colors.purpleAccent;
    canvas.drawCircle(geometry.getTubeStart(size), 5, dotPaint);
  }

  @override
  bool shouldRepaint(TubeFlowPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.flowOffset != flowOffset ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.geometry != geometry ||
        oldDelegate.tubeWidth != tubeWidth ||
        oldDelegate.bloodWidth != bloodWidth;
  }
}
