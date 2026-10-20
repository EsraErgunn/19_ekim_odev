import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Tamamlanma anında üst porta elastik animasyonla takılan 3D tıbbi kapama klipsini çizen CustomPainter.
class SealingClipPainter extends CustomPainter {
  SealingClipPainter({
    required this.clipProgress,
    required this.portOffset,
  });

  /// 0.0 - 1.0 arası elastik giriş animasyon değeri
  final double clipProgress;

  /// Torbanın üst port koordinatı
  final Offset portOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (clipProgress <= 0.0) return;

    canvas.save();
    canvas.translate(portOffset.dx, portOffset.dy);

    // Elastic scale ve hafif rotasyon
    final scale = clipProgress.clamp(0.0, 1.3);
    canvas.scale(scale);

    // 1. Klipsin gölgesi
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-16, -10, 32, 22),
        const Radius.circular(6),
      ),
      shadowPaint,
    );

    // 2. Klips gövdesi (Turkuaz - İyileşme rengi)
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

    // 3. Sağ kilit halkası (Koyu mavi/metalik mandal)
    final claspPaint = Paint()
      ..color = const Color(0xFF0369A1)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(11, -7, 10, 14),
        const Radius.circular(4),
      ),
      claspPaint,
    );

    // 4. Merkezi kilit düğmesi / valf pimi (Kırmızı vurgulu yuvarlak buton)
    final knobPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Colors.white,
          AppColors.bloodRedLight,
          AppColors.bloodRedDark,
        ],
      ).createShader(const Rect.fromLTWH(-6, -6, 12, 12));
    canvas.drawCircle(Offset.zero, 6.0, knobPaint);

    // Düğme iç halkası
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset.zero, 3.2, ringPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(SealingClipPainter oldDelegate) {
    return oldDelegate.clipProgress != clipProgress ||
        oldDelegate.portOffset != portOffset;
  }
}
