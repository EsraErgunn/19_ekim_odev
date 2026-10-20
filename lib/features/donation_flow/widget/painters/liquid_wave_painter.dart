import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Torbanın içindeki kan sıvısını maske ile tam torba şeklinde, çift dalga ve hacimli çizen CustomPainter.
class LiquidWavePainter extends CustomPainter {
  LiquidWavePainter({
    required this.maskImage,
    required this.fill,
    required this.phase,
    required this.waveAmplitude,
    this.sloshAmplitude = 0.0,
    this.bubbleProgress = 0.0,
    this.isActive = false,
    this.primaryColor = AppColors.bloodRed,
    this.darkColor = AppColors.bloodRedDark,
    this.crestColor = AppColors.bloodRedGlow,
  });

  /// Torba iç bölme maskesi (BlendMode.dstIn ile kırpmak için)
  final ui.Image? maskImage;

  /// Doluluk oranı (0.0 - 1.0)
  final double fill;

  /// Ana dalga faz açısı (0 - 2π radyan)
  final double phase;

  /// Temel dalga genliği
  final double waveAmplitude;

  /// Dolum anında çalkalanma genliği (sönümlenen ekstra genlik)
  final double sloshAmplitude;

  /// Kabarcık yükselme döngüsü (0.0 - 1.0)
  final double bubbleProgress;

  /// Aktif akış durumu (kabarcıklar aktifken yükselir)
  final bool isActive;

  final Color primaryColor;
  final Color darkColor;
  final Color crestColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Maske yüklenmeden sıvı çizilmez (ilk karede taşma olmaması için)
    if (maskImage == null) return;

    final bounds = Offset.zero & size;

    // 1. Maskeleme için izole katman aç
    canvas.saveLayer(bounds, Paint());

    final chamberBottom = size.height * 0.835;
    const chamberTop = 0.0;
    final totalHeight = chamberBottom - chamberTop;
    final clampedFill = fill.clamp(0.0, 1.0);
    final surfaceY = chamberBottom - (totalHeight * clampedFill);
    final totalAmp = waveAmplitude + sloshAmplitude;

    // 2. Arka Dalga Katmanı (4-6 px daha yüksekte, daha koyu, farklı faz ve hız)
    _drawBackWave(canvas, size, surfaceY, totalAmp, chamberBottom);

    // 3. Ön Dalga Katmanı (Hacimli yatay gradient ile silindirik derinlik)
    final crestPath = _drawFrontWave(canvas, size, surfaceY, totalAmp, chamberBottom);

    // 4. Yüzey Menisküs Çizgileri
    _drawMeniscus(canvas, crestPath);

    // 5. Sol Dikey Yumuşak Parlama Şeridi (MaskFilter.blur ile)
    _drawLeftGlossStrip(canvas, size, surfaceY, chamberBottom);

    // 6. Yükselen Kabarcıklar (Yalnızca aktif aşamada)
    if (isActive && clampedFill > 0.02) {
      _drawRisingBubbles(canvas, size, surfaceY, chamberBottom);
    }

    // 7. Torba Maskesini BlendMode.dstIn ile uygula
    final maskPaint = Paint()..blendMode = BlendMode.dstIn;
    canvas.drawImageRect(
      maskImage!,
      Rect.fromLTWH(0, 0, maskImage!.width.toDouble(), maskImage!.height.toDouble()),
      bounds,
      maskPaint,
    );

    canvas.restore();
  }

  void _drawBackWave(
    Canvas canvas,
    Size size,
    double surfaceY,
    double totalAmp,
    double chamberBottom,
  ) {
    const backOffset = 5.0; // 4-6 px yüksekte
    final backSurfaceY = surfaceY - backOffset;
    final backPhase = (phase * 1.35) + 1.2;

    final backWavePath = Path()..moveTo(0, chamberBottom + 20);
    backWavePath.lineTo(0, backSurfaceY);

    for (double x = 0; x <= size.width; x += 2.0) {
      final y = backSurfaceY +
          (totalAmp * 0.7) * math.sin((x / size.width * 2.4 * math.pi) + backPhase);
      backWavePath.lineTo(x, y);
    }

    backWavePath
      ..lineTo(size.width, chamberBottom + 20)
      ..close();

    final backPaint = Paint()
      ..color = darkColor.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;

    canvas.drawPath(backWavePath, backPaint);
  }

  Path _drawFrontWave(
    Canvas canvas,
    Size size,
    double surfaceY,
    double totalAmp,
    double chamberBottom,
  ) {
    final frontWavePath = Path()..moveTo(0, chamberBottom + 20);
    final crestPath = Path();

    var isFirst = true;
    for (double x = 0; x <= size.width; x += 1.5) {
      final y = surfaceY +
          totalAmp * math.sin((x / size.width * 2.0 * math.pi) + phase);

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
      ..lineTo(size.width, chamberBottom + 20)
      ..close();

    // Dikey renk geçişi (altta koyu, üstte canlı kırmızı)
    final verticalGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [darkColor, primaryColor],
    );

    final fillPaint = Paint()
      ..shader = verticalGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    canvas.drawPath(frontWavePath, fillPaint);

    // Yatay gradient ile kenarları %25 koyulaştır (silindir hacmi hissi)
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

    final shadePaint = Paint()
      ..shader = sideShadeGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    canvas.drawPath(frontWavePath, shadePaint);

    return crestPath;
  }

  void _drawMeniscus(Canvas canvas, Path crestPath) {
    // Yüzey parlaması
    final crestPaint = Paint()
      ..color = crestColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(crestPath, crestPaint);

    // Yüzeyin hemen altında açık renkli ince menisküs bandı
    canvas.save();
    canvas.translate(0, 2.5);
    final meniscusPaint = Paint()
      ..color = crestColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(crestPath, meniscusPaint);
    canvas.restore();
  }

  void _drawLeftGlossStrip(
    Canvas canvas,
    Size size,
    double surfaceY,
    double chamberBottom,
  ) {
    final glossLeft = size.width * 0.26;
    final glossTop = surfaceY + 6.0;
    final glossWidth = size.width * 0.065;
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
  }

  void _drawRisingBubbles(
    Canvas canvas,
    Size size,
    double surfaceY,
    double chamberBottom,
  ) {
    final bubblePaint = Paint()..style = PaintingStyle.fill;
    const bubbleCount = 7;

    for (int i = 0; i < bubbleCount; i++) {
      final speedFactor = 0.8 + ((i % 3) * 0.25);
      final t = (bubbleProgress * speedFactor + (i * 0.15)) % 1.0;
      final bubbleY = chamberBottom - (t * (chamberBottom - surfaceY));

      if (bubbleY > surfaceY + 2.0) {
        final wobble = 2.5 * math.sin((t * 4 * math.pi) + i);
        final bubbleX = (size.width * (0.28 + (i * 0.065))) + wobble;
        final fade = math.sin(t * math.pi);
        final radius = 1.3 + ((i % 3) * 0.5);

        bubblePaint.color = Colors.white.withValues(alpha: (fade * 0.55).clamp(0.0, 1.0));
        canvas.drawCircle(Offset(bubbleX, bubbleY), radius, bubblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(LiquidWavePainter oldDelegate) {
    return oldDelegate.maskImage != maskImage ||
        oldDelegate.fill != fill ||
        oldDelegate.phase != phase ||
        oldDelegate.waveAmplitude != waveAmplitude ||
        oldDelegate.sloshAmplitude != sloshAmplitude ||
        oldDelegate.bubbleProgress != bubbleProgress ||
        oldDelegate.isActive != isActive ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.darkColor != darkColor ||
        oldDelegate.crestColor != crestColor;
  }
}
