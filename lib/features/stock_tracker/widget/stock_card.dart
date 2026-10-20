import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/blood_group_stock.dart';
import 'blood_compatibility_sheet.dart';

/// Her bir kan grubu için stok durumu kartı
class StockCard extends StatelessWidget {
  const StockCard({super.key, required this.stock});

  final BloodGroupStock stock;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => BloodCompatibilitySheet.show(context, stock),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: stock.status == BloodStockStatus.critical
                ? AppColors.bloodRed.withValues(alpha: 0.6)
                : (isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopRow(isDark),
            const SizedBox(height: 12),
            _buildProgressBar(),
            const SizedBox(height: 8),
            _buildBottomUnitsRow(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bloodRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.water_drop_rounded, color: AppColors.bloodRed, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              stock.bloodType,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (stock.isRare) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Nadir', style: TextStyle(color: AppColors.goldDark, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: stock.status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: stock.status.color.withValues(alpha: 0.4)),
      ),
      child: Text(
        stock.status.label,
        style: TextStyle(
          color: stock.status.color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: stock.fillRatio,
        minHeight: 8,
        backgroundColor: stock.status.color.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation<Color>(stock.status.color),
      ),
    );
  }

  Widget _buildBottomUnitsRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mevcut: ${stock.currentUnits} / Hedef: ${stock.targetUnits} Ünite',
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          '%${(stock.fillRatio * 100).toInt()}',
          style: TextStyle(
            color: stock.status.color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
