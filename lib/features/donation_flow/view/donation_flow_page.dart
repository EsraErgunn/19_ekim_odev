import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../controller/donation_session_controller.dart';
import '../controller/simulation_clock.dart';
import '../models/bag_geometry.dart';
import '../models/donation_stage.dart';
import '../widget/donation_summary_card.dart';
import '../widget/eligibility_form.dart';
import '../widget/flow_rate_chart.dart';
import '../widget/layered_blood_bag.dart';
import '../widget/painters/radial_progress_painter.dart';
import '../widget/preparation_steps.dart';
import '../widget/resting_timer.dart';
import '../widget/squeeze_button.dart';

/// Modül G1: Çok Aşamalı Bağış Simülasyonu ve Katmanlı Kan Torbası Sayfası
class DonationFlowPage extends StatefulWidget {
  const DonationFlowPage({super.key, this.controller});

  final DonationSessionController? controller;

  @override
  State<DonationFlowPage> createState() => _DonationFlowPageState();
}

class _DonationFlowPageState extends State<DonationFlowPage> {
  late final DonationSessionController _controller;
  bool _ownsController = false;

  final ValueNotifier<bool> _showOverlayNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showMaskNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = DonationSessionController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    _showOverlayNotifier.dispose();
    _showMaskNotifier.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidianBackground : AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            _controller,
            _controller.clock,
            _showOverlayNotifier,
            _showMaskNotifier,
            ThemeController.instance.themeModeNotifier,
          ]),
          builder: (context, _) => _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Bağış Süreci (Modül G1)'),
      actions: [
        IconButton(
          tooltip: ThemeController.instance.isDarkMode ? 'Aydınlık Mod' : 'Koyu Mod',
          icon: Icon(
            ThemeController.instance.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: ThemeController.instance.isDarkMode ? AppColors.gold : AppColors.bloodRed,
          ),
          onPressed: ThemeController.instance.toggleTheme,
        ),
        _buildSpeedSelector(),
        if (kDebugMode) ...[
          IconButton(
            tooltip: 'Maske Kontrolü (%40 Yeşil)',
            icon: Icon(
              _showMaskNotifier.value ? Icons.layers : Icons.layers_outlined,
              color: _showMaskNotifier.value ? Colors.greenAccent : AppColors.textMuted,
            ),
            onPressed: () => _showMaskNotifier.value = !_showMaskNotifier.value,
          ),
          IconButton(
            tooltip: 'Geometri Kılavuzu',
            icon: Icon(
              _showOverlayNotifier.value ? Icons.grid_on_rounded : Icons.grid_off_rounded,
              color: _showOverlayNotifier.value ? AppColors.recoveryTeal : AppColors.textMuted,
            ),
            onPressed: () => _showOverlayNotifier.value = !_showOverlayNotifier.value,
          ),
        ],
      ],
    );
  }

  Widget _buildSpeedSelector() {
    return PopupMenuButton<SimulationSpeed>(
      tooltip: 'Zaman Ölçeği',
      initialValue: _controller.clock.speed,
      onSelected: (speed) => _controller.clock.setSpeed(speed),
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cardSurfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          _controller.clock.speed.name.replaceAll('ultraFast', '').replaceAll('fast', '').replaceAll('realTime', ''),
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
      itemBuilder: (context) => [
        for (final s in SimulationSpeed.values)
          PopupMenuItem(value: s, child: Text(s.label)),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _StageBadge(stage: _controller.stage),
          if (kDebugMode) _buildDebugFillRow(),
          const SizedBox(height: 12),
          _BagWithRingSection(
            fillRatio: _controller.fillRatio,
            stage: _controller.stage,
            showMask: _showMaskNotifier.value,
            showOverlay: _showOverlayNotifier.value,
          ),
          const SizedBox(height: 16),
          _MetricsCard(controller: _controller),
          const SizedBox(height: 18),
          _buildStageContent(),
        ],
      ),
    );
  }

  Widget _buildDebugFillRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test:', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(width: 6),
          _DebugButton(label: '%20', onTap: () => _controller.debugSetCollectedMl(90)),
          const SizedBox(width: 6),
          _DebugButton(label: '%60', onTap: () => _controller.debugSetCollectedMl(270)),
          const SizedBox(width: 6),
          _DebugButton(label: '%100', onTap: () => _controller.debugSetCollectedMl(450)),
        ],
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_controller.stage) {
      case DonationStage.eligibility:
        return EligibilityForm(controller: _controller);
      case DonationStage.preparation:
        return PreparationSteps(controller: _controller);
      case DonationStage.active:
      case DonationStage.paused:
        return Column(
          children: [
            FlowRateChart(controller: _controller),
            const SizedBox(height: 14),
            SqueezeButton(controller: _controller),
            const SizedBox(height: 14),
            _ActiveActionControls(controller: _controller),
          ],
        );
      case DonationStage.closing:
        return _buildClosingBanner();
      case DonationStage.resting:
        return RestingTimer(controller: _controller);
      case DonationStage.completed:
        return DonationSummaryCard(controller: _controller);
      case DonationStage.cancelled:
        return _buildCancelledCard();
    }
  }

  Widget _buildClosingBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.recoveryTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(color: AppColors.recoveryTeal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Torba Mühürleniyor (Simülasyon)',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Hedef 450 ml kan toplandı, klips takılıyor.',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
      ),
      child: Column(
        children: [
          const Text('Bağış İşlemi İptal Edildi', style: TextStyle(color: AppColors.bloodRedLight, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _controller.resetToEligibility,
            child: const Text('Başa Dön'),
          ),
        ],
      ),
    );
  }
}

class _DebugButton extends StatelessWidget {
  const _DebugButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.cardSurfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(label, style: const TextStyle(color: AppColors.recoveryTeal, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.stage});
  final DonationStage stage;

  @override
  Widget build(BuildContext context) {
    final color = stage.isCompleted
        ? AppColors.gold
        : (stage.isActive ? AppColors.bloodRed : AppColors.recoveryTeal);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(stage.label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BagWithRingSection extends StatelessWidget {
  const _BagWithRingSection({
    required this.fillRatio,
    required this.stage,
    required this.showMask,
    required this.showOverlay,
  });

  final double fillRatio;
  final DonationStage stage;
  final bool showMask;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: fillRatio),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, animatedFill, _) {
        return SizedBox(
          width: 290,
          height: 350,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: RadialProgressPainter(
                      progress: animatedFill,
                      strokeWidth: 8.5,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 230,
                child: LayeredBloodBag(
                  fillRatio: animatedFill,
                  stage: stage,
                  geometry: BagGeometry(showGeometryOverlay: showOverlay),
                  showDebugMask: showMask,
                  showGeometryOverlay: showOverlay,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.controller});
  final DonationSessionController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentText = '%${(controller.fillRatio * 100).toInt()}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toplanan Kan (Simülasyon)',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${controller.collectedMl} / ${controller.targetMl} ml',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bloodRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              percentText,
              style: const TextStyle(
                color: AppColors.bloodRedLight,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveActionControls extends StatelessWidget {
  const _ActiveActionControls({required this.controller});
  final DonationSessionController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              key: const Key('pause_resume_button'),
              onPressed: controller.stage.isActive
                  ? controller.pauseDonation
                  : controller.resumeDonation,
              icon: Icon(controller.stage.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(controller.stage.isActive ? 'Duraklat' : 'Devam Et'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            key: const Key('cancel_button'),
            onPressed: () => _confirmCancel(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.cardBorder),
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('İptal Et'),
          ),
        ),
      ],
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text('Bağışı İptal Et?'),
        content: const Text('Devam eden bağış akışı durdurulacaktır. Onaylıyor musunuz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.bloodRed),
            onPressed: () {
              Navigator.pop(ctx);
              controller.cancelDonation();
            },
            child: const Text('Evet, İptal Et'),
          ),
        ],
      ),
    );
  }
}
