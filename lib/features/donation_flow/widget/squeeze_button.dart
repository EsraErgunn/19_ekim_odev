import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/donation_session_controller.dart';

/// 3. Aşama: Akış hızlandırıcı "Topu Sık" interaktif butonu ve uyarı paneli
class SqueezeButton extends StatefulWidget {
  const SqueezeButton({super.key, required this.controller});

  final DonationSessionController controller;

  @override
  State<SqueezeButton> createState() => _SqueezeButtonState();
}

class _SqueezeButtonState extends State<SqueezeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSqueezing = widget.controller.isSqueezing;
    final warning = widget.controller.needsSqueezeWarning;

    return Column(
      children: [
        if (warning) _buildWarningBanner(),
        const SizedBox(height: 10),
        _buildInteractiveBall(isSqueezing, warning),
      ],
    );
  }

  Widget _buildWarningBanner() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final glow = _pulseController.value;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFF7F1D1D),
              const Color(0xFF991B1B),
              glow,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.bloodRedLight),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Akış yavaşladı! Hızı korumak için topu sıkın (x1.2)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInteractiveBall(bool isSqueezing, bool warning) {
    return Listener(
      onPointerDown: (_) => widget.controller.setSqueezing(true),
      onPointerUp: (_) => widget.controller.setSqueezing(false),
      onPointerCancel: (_) => widget.controller.setSqueezing(false),
      child: AnimatedScale(
        scale: isSqueezing ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuad,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSqueezing
                  ? [AppColors.bloodRedDark, AppColors.bloodRed]
                  : (warning
                      ? [const Color(0xFFB45309), const Color(0xFFD97706)]
                      : [AppColors.cardSurfaceElevated, AppColors.cardSurface]),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSqueezing
                  ? AppColors.bloodRedLight
                  : (warning ? AppColors.gold : AppColors.cardBorder),
              width: 1.5,
            ),
            boxShadow: isSqueezing
                ? [
                    BoxShadow(
                      color: AppColors.bloodRed.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSqueezing ? Icons.compress_rounded : Icons.sports_baseball_rounded,
                color: isSqueezing ? Colors.white : AppColors.textPrimary,
                size: 26,
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSqueezing ? 'Top Sıkılıyor (Akış Hızı: x1.2)' : 'Topu Sık (Basılı Tut)',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Basılı tutarak kan akışını hızlandırın',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
