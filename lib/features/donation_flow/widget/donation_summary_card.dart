import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/donation_session_controller.dart';

/// 6. Aşama: Bağış Tamamlandı Özet Kartı
class DonationSummaryCard extends StatelessWidget {
  const DonationSummaryCard({super.key, required this.controller});

  final DonationSessionController controller;

  @override
  Widget build(BuildContext context) {
    final elapsed = controller.elapsedSimulationTime;
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final timeStr = '$minutes dk $seconds sn';

    final avgRate = elapsed.inSeconds > 0
        ? (controller.collectedMl / (elapsed.inSeconds / 60.0))
        : 50.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBadgeHeader(),
          const SizedBox(height: 18),
          _buildStatsGrid(timeStr, avgRate),
          const SizedBox(height: 18),
          _buildImpactMessage(),
          const SizedBox(height: 20),
          _buildRestartButton(),
        ],
      ),
    );
  }

  Widget _buildBadgeHeader() {
    return const Column(
      children: [
        Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 48),
        SizedBox(height: 8),
        Text(
          'Bağış Başarıyla Tamamlandı!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '+150 Puan ve "Hayat Kurtaran" Rozeti Kazandınız',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(String timeStr, double avgRate) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(
            label: 'Toplanan Hacim',
            value: '${controller.collectedMl} ml',
            icon: Icons.water_drop_rounded,
            color: AppColors.bloodRedLight,
          ),
          _StatColumn(
            label: 'Simülasyon Süresi',
            value: timeStr,
            icon: Icons.timer_outlined,
            color: AppColors.recoveryTeal,
          ),
          _StatColumn(
            label: 'Ortalama Hız',
            value: '${avgRate.toStringAsFixed(1)} ml/dk',
            icon: Icons.speed_rounded,
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.recoveryTeal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.recoveryTeal.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_rounded, color: AppColors.recoveryTeal, size: 20),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              '1 ünite kan bağışınızla 3 cana umut oldunuz!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestartButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        key: const Key('new_donation_button'),
        onPressed: controller.resetToEligibility,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Yeni Bağış Oturumu Başlat'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.recoveryTeal,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}
