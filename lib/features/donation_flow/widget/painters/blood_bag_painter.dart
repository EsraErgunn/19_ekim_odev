import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/bag_geometry.dart';
import '../../models/donation_stage.dart';

/// Tüm kan torbası görselini, sıvısını, maskesini ve parlamasını TEK bir tuvalde çizen ana painter.
class BloodBagPainter extends CustomPainter {
  BloodBagPainter({
    required this.bagEmptyImage,
    required this.maskImage,
    required this.fillRatio,
    required this.wavePhase,
    required this.waveAmplitude,
    this.sloshAmplitude = 0.0,
    this.bubbleProgress = 0.0,
    this.tubeFlowOffset = 0.0,
    this.clipProgress = 0.0,
    this.sparkleProgress = 0.0,
    required this.stage,
    this.geometry = const BagGeometry(),
    this.showDebugMask = false,
    this.showGeometryOverlay = false,
    this.primaryColor = AppColors.bloodRed,
    this.darkColor = AppColors.bloodRedDark,
    this.crestColor = AppColors.bloodRedGlow,
  }) {
    // Doğrulama: Maske ve görsel piksel boyutu farklıysa debug'da açık FlutterError fırlat
    assert(() {
      if (bagEmptyImage.width != maskImage.width ||
          bagEmptyImage.height != maskImage.height) {
        throw FlutterError(
          'BloodBagPainter Doğrulama Hatası: bag_empty boyutu (${bagEmptyImage.width}x${bagEmptyImage.height}) '
          'ile bag_mask boyutu (${maskImage.width}x${maskImage.height}) birebir aynı olmalıdır!',
        );
      }
      return true;
    }());
  }

  final ui.Image bagEmptyImage;
  final ui.Image maskImage;
  final double fillRatio;
  final double wavePhase;
  final double waveAmplitude;
  final double sloshAmplitude;
  final double bubbleProgress;
  final double tubeFlowOffset;
  final double clipProgress;
  final double sparkleProgress;
  final DonationStage stage;
  final BagGeometry geometry;
  final bool showDebugMask;
  final bool showGeometryOverlay;

  final Color primaryColor;
  final Color darkColor;
  final Color crestColor;

  @override
  void paint(Canvas canvas, Size size) {
    final srcRect = Rect.fromLTWH(
      0,
      0,
      bagEmptyImage.width.toDouble(),
      bagEmptyImage.height.toDouble(),
    );
    final dstRect = Offset.zero & size;

    // 1. Katman: Boş torba görseli (tam opaklık)
    canvas.drawImageRect(bagEmptyImage, srcRect, dstRect, Paint());

    // 2. Katman: Sıvı (saveLayer -> sıvı çiz -> maskeyi BlendMode.dstIn ile aynı dstRect'e çiz -> restore)
    _paintMaskedLiquid(canvas, srcRect, dstRect);

    // 3. Katman: Parlama (aynı görsel BlendMode.screen ile %50 opaklıkta en üste çizilir)
    final highlightPaint = Paint()
      ..blendMode = BlendMode.screen
      ..color = const Color.fromRGBO(255, 255, 255, 0.50);
    canvas.drawImageRect(bagEmptyImage, srcRect, dstRect, highlightPaint);

    // 4. Katman: Plastik tüp (aynı dstRect koordinat oranlarına göre)
    _paintTube(canvas, dstRect);

    // 5. Katman: Üst port sıçrama damlacıkları (yalnızca aktifte)
    if (stage.isActive) {
      _paintSplash(canvas, dstRect);
    }

    // 6. Katman: Mühürleme klipsi (closing, resting, completed aşamalarında)
    if (clipProgress > 0.0 || stage.isClosing || stage.isResting || stage.isCompleted) {
      _paintSealingClip(canvas, dstRect);
    }

    // 7. Katman: Kutlama parıltıları (yalnızca completed aşamasında)
    if (stage.isCompleted) {
      _paintSparkles(canvas, dstRect);
    }

    // 8. Katman: Kontrol modu (yalnızca kDebugMode aktifken yeşil %40 opak maske)
    if (kDebugMode && showDebugMask) {
      _paintDebugMask(canvas, srcRect, dstRect);
    }

    if (kDebugMode && showGeometryOverlay) {
      _paintDebugGeometry(canvas, dstRect);
    }
  }

  void _paintMaskedLiquid(Canvas canvas, Rect srcRect, Rect dstRect) {
    canvas.saveLayer(dstRect, Paint());

    final chamberBottom = dstRect.bottom * 0.835;
    const chamberTop = 0.0;
    final totalHeight = chamberBottom - chamberTop;
    final clampedFill = fillRatio.clamp(0.0, 1.0);
    final surfaceY = chamberBottom - (totalHeight * clampedFill);
    final totalAmp = waveAmplitude + sloshAmplitude;

    // A. Arka Dalga (4-6 px daha yüksek, daha koyu, farklı hız)
    const backOffset = 5.0;
    final backSurfaceY = surfaceY - backOffset;
    final backPhase = (wavePhase * 1.35) + 1.2;

    final backWavePath = Path()..moveTo(dstRect.left, chamberBottom + 20);
    backWavePath.lineTo(dstRect.left, backSurfaceY);

    for (double x = dstRect.left; x <= dstRect.right; x += 2.0) {
      final y = backSurfaceY +
          (totalAmp * 0.7) * math.sin((x / dstRect.width * 2.4 * math.pi) + backPhase);
      backWavePath.lineTo(x, y);
    }
    backWavePath
      ..lineTo(dstRect.right, chamberBottom + 20)
      ..close();

    final backPaint = Paint()
      ..color = darkColor.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    canvas.drawPath(backWavePath, backPaint);

    // B. Ön Dalga (Hacimli silindirik yatay gradient)
    final frontWavePath = Path()..moveTo(dstRect.left, chamberBottom + 20);
    final crestPath = Path();

    var isFirst = true;
    for (double x = dstRect.left; x <= dstRect.right; x += 1.5) {
      final y = surfaceY +
          totalAmp * math.sin((x / dstRect.width * 2.0 * math.pi) + wavePhase);

      if (isFirst) {
        frontWavePath.lineTo(x, y);
        crestPath.moveTo(x, y);
        isFirst = false;
      } else {
        frontWavePath.lineTo(x, y);
        crestPath.lineTo(x, y);
      }
    }
    frontWavePath
      ..lineTo(dstRect.right, chamberBottom + 20)
      ..close();

    // Dikey gradient (altta koyu, üstte canlı kırmızı)
    final verticalGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [darkColor, primaryColor],
    );
    canvas.drawPath(
      frontWavePath,
      Paint()
        ..shader = verticalGradient.createShader(dstRect)
        ..style = PaintingStyle.fill,
    );

    // Yatay gradient: kenarları %25 koyulaştır (silindir hacmi hissi)
    final sideShadeGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.black.withValues(alpha: 0.28),
        Colors.transparent,
        Colors.transparent,
        Colors.black.withValues(alpha: 0.28),
      ],
      stops: const [0.0, 0.24, 0.76, 1.0],
    );
    canvas.drawPath(
      frontWavePath,
      Paint()
        ..shader = sideShadeGradient.createShader(dstRect)
        ..style = PaintingStyle.fill,
    );

    // C. Yüzey Menisküs Çizgileri
    final crestPaint = Paint()
      ..color = crestColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(crestPath, crestPaint);

    canvas.save();
    canvas.translate(0, 2.5);
    final meniscusPaint = Paint()
      ..color = crestColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(crestPath, meniscusPaint);
    canvas.restore();

    // D. Sol Dikey Yumuşak Parlama Şeridi (MaskFilter.blur ile)
    final glossLeft = dstRect.left + dstRect.width * 0.26;
    final glossTop = surfaceY + 6.0;
    final glossWidth = dstRect.width * 0.065;
    final glossHeight = math.max(0.0, chamberBottom - surfaceY - 12.0);

    if (glossHeight > 5.0) {
      final glossRect = Rect.fromLTWH(glossLeft, glossTop, glossWidth, glossHeight);
      final glossPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(glossRect, const Radius.circular(8)),
        glossPaint,
      );
    }

    // E. Aktif aşamada yükselen kabarcıklar
    if (stage.isActive && clampedFill > 0.02) {
      final bubblePaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 7; i++) {
        final speedFactor = 0.8 + ((i % 3) * 0.25);
        final t = (bubbleProgress * speedFactor + (i * 0.15)) % 1.0;
        final bubbleY = chamberBottom - (t * (chamberBottom - surfaceY));

        if (bubbleY > surfaceY + 2.0) {
          final wobble = 2.5 * math.sin((t * 4 * math.pi) + i);
          final bubbleX = dstRect.left + (dstRect.width * (0.28 + (i * 0.065))) + wobble;
          final fade = math.sin(t * math.pi);
          final radius = 1.3 + ((i % 3) * 0.5);

          bubblePaint.color = Colors.white.withValues(alpha: (fade * 0.55).clamp(0.0, 1.0));
          canvas.drawCircle(Offset(bubbleX, bubbleY), radius, bubblePaint);
        }
      }
    }

    // F. Maskeyi BlendMode.dstIn ile aynı dstRect üzerine uygula
    final maskPaint = Paint()..blendMode = BlendMode.dstIn;
    canvas.drawImageRect(maskImage, srcRect, dstRect, maskPaint);

    canvas.restore();
  }

  void _paintTube(Canvas canvas, Rect dstRect) {
    final tubePath = geometry.getTubePath(dstRect.size);
    final metrics = tubePath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    const tubeWidth = 11.5;
    const bloodWidth = 5.2;

    // 1. Dış katman: kalın yarı saydam silikon plastik
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

    // 2. İç katman: dolu akış
    final isFilled = stage.isActive || stage.isClosing || stage.isResting || stage.isCompleted;
    if (isFilled) {
      final filledPath = metric.extractPath(0.0, metric.length);
      final bloodPaint = Paint()
        ..color = AppColors.bloodRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = bloodWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(filledPath, bloodPaint);

      // Aktif aşamada akan kabarcıklar
      if (stage.isActive) {
        final bubblePaint = Paint()..style = PaintingStyle.fill;
        for (int i = 0; i < 4; i++) {
          final t = ((tubeFlowOffset + (i / 4.0)) % 1.0);
          final distance = t * metric.length;
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            bubblePaint.color = AppColors.bloodRedLight.withValues(alpha: 0.90);
            canvas.drawCircle(tangent.position, 2.0, bubblePaint);
          }
        }
      }
    }

    // 3. Üst parlama çizgisi
    canvas.save();
    canvas.translate(-1.0, -1.0);
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(tubePath, highlightPaint);
    canvas.restore();
  }

  void _paintSplash(Canvas canvas, Rect dstRect) {
    final port = geometry.getPortOffset(dstRect.size);
    final paint = Paint()..style = PaintingStyle.fill;
    const particleCount = 8;

    for (int i = 0; i < particleCount; i++) {
      final t = (bubbleProgress + (i / particleCount)) % 1.0;
      final spread = -math.pi / 2 + ((i - (particleCount - 1) / 2) * 0.28);
      const velocity = 38.0;
      const gravity = 110.0;

      final dx = math.cos(spread) * velocity * t;
      final dy = math.sin(spread) * velocity * t + 0.5 * gravity * t * t;
      final alpha = (1.0 - t).clamp(0.0, 1.0);

      paint.color = AppColors.bloodRedLight.withValues(alpha: alpha * 0.9);
      canvas.drawCircle(Offset(port.dx + dx, port.dy + dy), 2.2, paint);
    }
  }

  void _paintSealingClip(Canvas canvas, Rect dstRect) {
    final port = geometry.getPortOffset(dstRect.size);
    canvas.save();
    canvas.translate(port.dx, port.dy);

    final scale = (clipProgress > 0 ? clipProgress : 1.0).clamp(0.0, 1.3);
    canvas.scale(scale);

    // Klips gövdesi
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.recoveryTealLight,
          AppColors.recoveryTeal,
          AppColors.recoveryTealDark,
        ],
      ).createShader(const Rect.fromLTWH(-15, -10, 30, 20))
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, -10, 30, 20),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Valf düğmesi
    final knobPaint = Paint()
      ..color = AppColors.bloodRedLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 5.5, knobPaint);

    canvas.restore();
  }

  void _paintSparkles(Canvas canvas, Rect dstRect) {
    const stars = [
      Offset(0.10, 0.22),
      Offset(0.88, 0.20),
      Offset(0.06, 0.56),
      Offset(0.92, 0.62),
      Offset(0.18, 0.82),
      Offset(0.84, 0.80),
      Offset(0.50, 0.06),
    ];

    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < stars.length; i++) {
      final posRatio = stars[i];
      final center = Offset(dstRect.width * posRatio.dx, dstRect.height * posRatio.dy);
      final twinkle = (math.sin((sparkleProgress * 2 * math.pi) + (i * 1.1)) + 1.0) / 2.0;
      final size = 13.0 * (0.45 + (0.55 * twinkle));

      paint.color = AppColors.gold.withValues(alpha: (0.3 + 0.7 * twinkle).clamp(0.0, 1.0));

      final path = Path();
      path.moveTo(center.dx, center.dy - size);
      path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
      path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
      path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
      path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintDebugMask(Canvas canvas, Rect srcRect, Rect dstRect) {
    canvas.saveLayer(dstRect, Paint());
    canvas.drawImageRect(maskImage, srcRect, dstRect, Paint());
    canvas.drawRect(
      dstRect,
      Paint()
        ..color = const Color(0x6600FF00) // Yeşil %40 opaklık
        ..blendMode = BlendMode.srcIn,
    );
    canvas.restore();
  }

  void _paintDebugGeometry(Canvas canvas, Rect dstRect) {
    final tubePath = geometry.getTubePath(dstRect.size);
    final pathPaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(tubePath, pathPaint);

    final dotPaint = Paint()..style = PaintingStyle.fill;
    dotPaint.color = Colors.greenAccent;
    canvas.drawCircle(geometry.getPortOffset(dstRect.size), 6, dotPaint);

    dotPaint.color = Colors.purpleAccent;
    canvas.drawCircle(geometry.getTubeStart(dstRect.size), 6, dotPaint);
  }

  @override
  bool shouldRepaint(BloodBagPainter oldDelegate) {
    return oldDelegate.bagEmptyImage != bagEmptyImage ||
        oldDelegate.maskImage != maskImage ||
        oldDelegate.fillRatio != fillRatio ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.waveAmplitude != waveAmplitude ||
        oldDelegate.sloshAmplitude != sloshAmplitude ||
        oldDelegate.bubbleProgress != bubbleProgress ||
        oldDelegate.tubeFlowOffset != tubeFlowOffset ||
        oldDelegate.clipProgress != clipProgress ||
        oldDelegate.sparkleProgress != sparkleProgress ||
        oldDelegate.stage != stage ||
        oldDelegate.geometry != geometry ||
        oldDelegate.showDebugMask != showDebugMask ||
        oldDelegate.showGeometryOverlay != showGeometryOverlay ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.darkColor != darkColor ||
        oldDelegate.crestColor != crestColor;
  }
}
