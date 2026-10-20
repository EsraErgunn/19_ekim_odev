import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_chart_theme.dart';
import '../controller/donation_session_controller.dart';

/// 3. Aşama: Canlı Akış Hızı Grafiği (Son 60 sn, ml/dk, fl_chart LineChart)
class FlowRateChart extends StatelessWidget {
  const FlowRateChart({super.key, required this.controller});

  final DonationSessionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsHeader(),
          const SizedBox(height: 14),
          SizedBox(height: 110, child: _buildLineChart()),
        ],
      ),
    );
  }

  Widget _buildMetricsHeader() {
    final elapsed = controller.elapsedSimulationTime;
    final remaining = controller.estimatedRemainingSimulationTime;

    final elapsedStr =
        '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    final remainingStr =
        '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anlık Akış Hızı (Simülasyon)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              '${controller.currentFlowRate.toStringAsFixed(1)} ml/dk',
              style: const TextStyle(
                color: AppColors.bloodRedLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _TimeBadge(label: 'Geçen', value: elapsedStr),
            const SizedBox(width: 8),
            _TimeBadge(label: 'Tahmini Kalan', value: remainingStr),
          ],
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    final history = controller.flowRateHistory;
    final spots = history.isEmpty
        ? [const FlSpot(0, 50)]
        : history.map((s) => FlSpot(s.simulationSecond, s.flowRateMlPerMin)).toList();

    final minX = spots.first.x;
    final maxX = spots.last.x > minX ? spots.last.x : minX + 1.0;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        minX: minX,
        maxX: maxX,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppChartTheme.primary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: AppChartTheme.areaGradient(AppChartTheme.primary),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
