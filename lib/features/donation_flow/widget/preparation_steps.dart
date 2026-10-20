import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/donation_session_controller.dart';

/// 2. Aşama: Ön Hazırlık Adımları ve 3-2-1 Geri Sayım
class PreparationSteps extends StatefulWidget {
  const PreparationSteps({super.key, required this.controller});

  final DonationSessionController controller;

  @override
  State<PreparationSteps> createState() => _PreparationStepsState();
}

class _PreparationStepsState extends State<PreparationSteps> {
  Timer? _countdownTimer;
  bool _isCounting = false;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (_isCounting) return;
    setState(() => _isCounting = true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.controller.preparationCountdown > 0) {
        widget.controller.decrementPreparationCountdown();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStepCard(
            stepNumber: 1,
            title: 'Turnike Bağlama',
            description: 'Koldaki venöz damar dolgunluğunu sağlamak için turnike sıkılır.',
            icon: Icons.airline_seat_recline_normal_rounded,
          ),
          const SizedBox(height: 10),
          _buildStepCard(
            stepNumber: 2,
            title: 'Bölge Dezenfeksiyonu',
            description: 'İğne giriş noktası antiseptik solüsyon ile dairesel temizlenir.',
            icon: Icons.clean_hands_rounded,
          ),
          const SizedBox(height: 10),
          _buildStepCard(
            stepNumber: 3,
            title: 'Damar Yolu Açılışı',
            description: 'Steril kan alma iğnesi tek seferde damara yerleştirilir.',
            icon: Icons.colorize_rounded,
          ),
          const SizedBox(height: 20),
          _buildCountdownAction(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(Icons.medical_services_outlined, color: AppColors.recoveryTeal, size: 26),
        SizedBox(width: 10),
        Text(
          'Hazırlık Adımları (Turnike & İğne)',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.recoveryTeal.withValues(alpha: 0.2),
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: AppColors.recoveryTeal,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  Widget _buildCountdownAction() {
    final count = widget.controller.preparationCountdown;

    if (_isCounting) {
      return Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bloodRedDark.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bloodRedLight),
        ),
        child: Text(
          'Akış Başlatılıyor: $count...',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        key: const Key('start_countdown_button'),
        onPressed: _startCountdown,
        icon: const Icon(Icons.play_circle_filled_rounded),
        label: const Text('Hazır — Akışı Başlat (3-2-1)'),
      ),
    );
  }
}
