import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Kan grubu stok durum seviyesi.
enum BloodStockStatus {
  critical('Kritik', AppColors.bloodRedLight, AppColors.bloodRedDark),
  low('Düşük', AppColors.warningOrange, Color(0xFF7C2D12)),
  sufficient('Yeterli', AppColors.infoBlue, Color(0xFF0369A1)),
  optimal('Optimal', AppColors.recoveryTeal, AppColors.recoveryTealDark);

  const BloodStockStatus(this.label, this.color, this.backgroundColor);
  final String label;
  final Color color;
  final Color backgroundColor;
}

/// Kan Grubu Stok Modeli.
class BloodGroupStock {
  const BloodGroupStock({
    required this.bloodType,
    required this.currentUnits,
    required this.targetUnits,
    required this.canDonateTo,
    required this.canReceiveFrom,
    this.isRare = false,
  });

  final String bloodType;
  final int currentUnits;
  final int targetUnits;
  final List<String> canDonateTo;
  final List<String> canReceiveFrom;
  final bool isRare;

  double get fillRatio => (currentUnits / targetUnits).clamp(0.0, 1.0);

  BloodStockStatus get status {
    final ratio = fillRatio;
    if (ratio < 0.35) return BloodStockStatus.critical;
    if (ratio < 0.65) return BloodStockStatus.low;
    if (ratio < 0.85) return BloodStockStatus.sufficient;
    return BloodStockStatus.optimal;
  }
}
