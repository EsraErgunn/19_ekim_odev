import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/donation_session_controller.dart';

/// 5. Aşama: 10 Dakika Dinlenme Sayacı ve Dönen Bakım İpuçları
class RestingTimer extends StatefulWidget {
  const RestingTimer({super.key, required this.controller});

  final DonationSessionController controller;

  @override
  State<RestingTimer> createState() => _RestingTimerState();
}

class _RestingTimerState extends State<RestingTimer> {
  int _currentTipIndex = 0;
  Timer? _tipTimer;

  static const List<_TipData> _tips = [
    _TipData(
      icon: Icons.local_drink_rounded,
      title: 'Bol Sıvı Tüketimi',
      message: 'Kan hacminizi hızla dengelemek için önümüzdeki 2-3 saatte bol su veya meyve suyu için.',
    ),
    _TipData(
      icon: Icons.fitness_center_rounded,
      title: 'Ağır Yükten Kaçının',
      message: 'Bağış yaptığınız kolunuzla bugün ağır kaldırmayın ve zorlayıcı egzersizlerden uzak durun.',
    ),
    _TipData(
      icon: Icons.airline_seat_recline_extra_rounded,
      title: 'Ani Hareket Etmeyin',
      message: 'Sedyeden yavaşça kalkın; baş dönmesi hissederseniz hemen uzanıp ayaklarınızı yükseltin.',
    ),
    _TipData(
      icon: Icons.restaurant_rounded,
      title: 'Demir Açısından Zengin Beslenin',
      message: 'Demir depolarınızı desteklemek için kırmızı et, yeşil yapraklı sebzeler ve C vitamini tüketin.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.controller.restingTimeRemaining;
    final min = remaining.inMinutes;
    final sec = remaining.inSeconds % 60;
    final timeStr = '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Text(
            'Zorunlu Dinlenme Süreci (Simülasyon)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _buildTimerDisplay(timeStr, remaining),
          const SizedBox(height: 16),
          _buildRotatingTipCard(),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(String timeStr, Duration remaining) {
    const totalSec = 10 * 60;
    final progress = (totalSec - remaining.inSeconds) / totalSec;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 6,
                backgroundColor: AppColors.cardSurfaceElevated,
                color: AppColors.recoveryTeal,
              ),
            ),
            const Icon(Icons.self_improvement_rounded, color: AppColors.recoveryTeal, size: 30),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeStr,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const Text(
              'Lütfen sedyede dinlenin',
              style: TextStyle(color: AppColors.recoveryTealLight, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRotatingTipCard() {
    final tip = _tips[_currentTipIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey<int>(_currentTipIndex),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.recoveryTeal.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(tip.icon, color: AppColors.gold, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tip.message,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipData {
  const _TipData({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;
}
