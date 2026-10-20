import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/emergency_request.dart';

/// Tek bir acil kan talebi kartı
class EmergencyRequestCard extends StatelessWidget {
  const EmergencyRequestCard({
    super.key,
    required this.request,
    required this.onSupport,
  });

  final EmergencyBloodRequest request;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: request.urgency == RequestUrgency.critical
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
          _buildHeaderRow(isDark),
          const SizedBox(height: 10),
          _buildDiagnosisRow(isDark),
          const SizedBox(height: 12),
          _buildProgressBar(),
          const SizedBox(height: 12),
          _buildFooterRow(isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bloodRed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.bloodRed.withValues(alpha: 0.4)),
          ),
          child: Text(
            request.bloodType,
            style: const TextStyle(
              color: AppColors.bloodRedLight,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.hospitalName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${request.city} • ${request.patientInitials}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildUrgencyBadge(),
      ],
    );
  }

  Widget _buildUrgencyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: request.urgency.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        request.urgency.label,
        style: TextStyle(
          color: request.urgency.color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDiagnosisRow(bool isDark) {
    return Text(
      'Gerekçe: ${request.diagnosis}',
      style: TextStyle(
        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
        fontSize: 13,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Toplanan: ${request.collectedUnits} / ${request.requiredUnits} Ünite',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              request.isFulfilled ? 'Tamamlandı' : 'Acil Destek Bekleniyor',
              style: TextStyle(
                color: request.isFulfilled ? AppColors.recoveryTeal : AppColors.bloodRedLight,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: request.progressRatio,
            minHeight: 7,
            backgroundColor: AppColors.bloodRed.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(
              request.isFulfilled ? AppColors.recoveryTeal : AppColors.bloodRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          request.contactPhone,
          style: TextStyle(
            color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
            fontSize: 12,
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: request.isFulfilled ? AppColors.recoveryTeal : AppColors.bloodRed,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: request.isFulfilled ? null : onSupport,
          child: Text(
            request.isFulfilled ? 'Karşılandı' : 'Bağış Desteği Ver',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
