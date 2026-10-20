import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Grafik ve veri görselleştirme modülleri için merkezi tema ve renk tanımları.
class AppChartTheme {
  const AppChartTheme._();

  static const Color primary = AppColors.bloodRed;
  static const Color primaryDark = AppColors.bloodRedDark;
  static const Color primaryLight = AppColors.bloodRedLight;
  static const Color crestHighlight = AppColors.bloodRedGlow;

  static const Color recovery = AppColors.recoveryTeal;
  static const Color gold = AppColors.gold;

  /// Dalgalı sıvı için dikey renk geçişi (koyu alt, açık üst).
  static const LinearGradient liquidGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      AppColors.bloodRedDark,
      AppColors.bloodRed,
      AppColors.bloodRedLight,
    ],
    stops: [0.0, 0.65, 1.0],
  );

  /// Dairesel ilerleme halkası için süpürme (sweep) gradient'i.
  static const SweepGradient radialProgressGradient = SweepGradient(
    startAngle: 0.0,
    endAngle: 6.283185307179586,
    colors: [
      AppColors.bloodRedDark,
      AppColors.bloodRed,
      AppColors.bloodRedLight,
      AppColors.bloodRed,
    ],
  );

  /// Alan grafikleri için dikey saydamlaşan gradient.
  static LinearGradient areaGradient(Color base) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          base.withValues(alpha: 0.35),
          base.withValues(alpha: 0.0),
        ],
      );
}
