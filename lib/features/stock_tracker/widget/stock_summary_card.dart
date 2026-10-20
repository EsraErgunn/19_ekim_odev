import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/blood_stock_controller.dart';

/// Stok Takibi Genel Özet Paneli
class StockSummaryCard extends StatelessWidget {
  const StockSummaryCard({super.key, required this.controller});

  final BloodStockController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 14),
          _buildMetricsRow(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_rounded, color: AppColors.bloodRed, size: 24),
            const SizedBox(width: 8),
            Text(
              'Ulusal Stok Durumu (Simülasyon)',
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.recoveryTeal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Canlı',
            style: TextStyle(color: AppColors.recoveryTeal, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow(bool isDark) {
    return Row(
      children: [
        _MetricItem(
          label: 'Toplam Stok',
          value: '${controller.totalUnits} Ünite',
          valueColor: AppColors.bloodRedLight,
          isDark: isDark,
        ),
        _MetricItem(
          label: 'Kritik Gruplar',
          value: '${controller.criticalGroupCount} Grup',
          valueColor: AppColors.warningOrange,
          isDark: isDark,
        ),
        _MetricItem(
          label: 'Doluluk',
          value: '%${(controller.overallFillRatio * 100).toInt()}',
          valueColor: AppColors.recoveryTeal,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isDark,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
