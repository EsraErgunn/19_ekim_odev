import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/blood_group_stock.dart';

/// Kan Grubu Uyumluluk ve Bilgilendirme Modalı
class BloodCompatibilitySheet extends StatelessWidget {
  const BloodCompatibilitySheet({super.key, required this.stock});

  final BloodGroupStock stock;

  static void show(BuildContext context, BloodGroupStock stock) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BloodCompatibilitySheet(stock: stock),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNavySurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          const SizedBox(height: 16),
          _buildTitleRow(isDark),
          const SizedBox(height: 20),
          _buildCompatibilitySection('Kimlere Kan Verebilir?', stock.canDonateTo, AppColors.recoveryTeal, isDark),
          const SizedBox(height: 16),
          _buildCompatibilitySection('Kimlerden Kan Alabilir?', stock.canReceiveFrom, AppColors.infoBlue, isDark),
          const SizedBox(height: 24),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textMuted.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitleRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stock.bloodType} Uyumluluk Rehberi',
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Stok Durumu: ${stock.status.label} (%${(stock.fillRatio * 100).toInt()})',
              style: TextStyle(color: stock.status.color, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompatibilitySection(String title, List<String> items, Color accentColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: accentColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                item,
                style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Anladım'),
      ),
    );
  }
}
