import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/donation_session_controller.dart';
import '../models/eligibility_input.dart';

/// 1. Aşama: Bağışçı Uygunluk Formu
class EligibilityForm extends StatefulWidget {
  const EligibilityForm({super.key, required this.controller});

  final DonationSessionController controller;

  @override
  State<EligibilityForm> createState() => _EligibilityFormState();
}

class _EligibilityFormState extends State<EligibilityForm> {
  int _age = 26;
  double _weight = 72;
  Gender _gender = Gender.male;
  final DateTime _lastDonation = DateTime.now().subtract(const Duration(days: 100));

  bool _meds = false;
  bool _alcohol = false;
  bool _piercing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 16),
          _buildAgeWeightRow(),
          const SizedBox(height: 14),
          _buildGenderSelector(),
          const SizedBox(height: 16),
          _buildHealthToggles(),
          const SizedBox(height: 16),
          if (widget.controller.eligibilityResult != null) _buildResultBanner(),
          const SizedBox(height: 16),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        const Icon(Icons.health_and_safety_rounded, color: AppColors.recoveryTeal, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bağışçı Uygunluk Kontrolü',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Sağlığınız ve alıcının güvenliği için kriterleri doğrulayın.',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgeWeightRow() {
    return Row(
      children: [
        Expanded(
          child: _NumberInputCard(
            label: 'Yaş',
            value: '$_age',
            onDecrement: () => setState(() => _age = (_age - 1).clamp(16, 75)),
            onIncrement: () => setState(() => _age = (_age + 1).clamp(16, 75)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NumberInputCard(
            label: 'Kilo (kg)',
            value: '${_weight.toInt()}',
            onDecrement: () => setState(() => _weight = (_weight - 2).clamp(40.0, 140.0)),
            onIncrement: () => setState(() => _weight = (_weight + 2).clamp(40.0, 140.0)),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cinsiyet:',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GenderOptionCard(
                label: 'Erkek (90 gün)',
                icon: Icons.male_rounded,
                isSelected: _gender == Gender.male,
                onTap: () => setState(() => _gender = Gender.male),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _GenderOptionCard(
                label: 'Kadın (120 gün)',
                icon: Icons.female_rounded,
                isSelected: _gender == Gender.female,
                onTap: () => setState(() => _gender = Gender.female),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthToggles() {
    return Column(
      children: [
        _HealthCheckbox(
          title: 'Sürekli ilaç kullanımı veya kronik hastalık var',
          value: _meds,
          onChanged: (v) => setState(() => _meds = v ?? false),
        ),
        _HealthCheckbox(
          title: 'Son 24 saat içinde alkol tüketildi',
          value: _alcohol,
          onChanged: (v) => setState(() => _alcohol = v ?? false),
        ),
        _HealthCheckbox(
          title: 'Son 12 ayda ameliyat, dövme veya piercing yapıldı',
          value: _piercing,
          onChanged: (v) => setState(() => _piercing = v ?? false),
        ),
      ],
    );
  }

  Widget _buildResultBanner() {
    final res = widget.controller.eligibilityResult!;
    if (res.isEligible) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.recoveryTeal.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.recoveryTeal),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.recoveryTeal),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tebrikler! Bağış için tüm kriterlere uygunsunuz.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bloodRedDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bloodRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.bloodRedLight),
              SizedBox(width: 8),
              Text(
                'Bağışa Uygun Değil:',
                style: TextStyle(color: AppColors.bloodRedLight, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final reason in res.rejectionReasons)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $reason', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        key: const Key('evaluate_button'),
        onPressed: _evaluateAndProceed,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('Uygunluğu Onayla ve Hazırlığa Geç'),
      ),
    );
  }

  void _evaluateAndProceed() {
    final input = EligibilityInput(
      age: _age,
      weightKg: _weight,
      gender: _gender,
      lastDonationDate: _lastDonation,
      hasChronicIllnessOrMeds: _meds,
      consumedAlcoholLast24Hours: _alcohol,
      recentPiercingOrSurgery: _piercing,
    );
    widget.controller.submitEligibility(input);
  }
}

class _NumberInputCard extends StatelessWidget {
  const _NumberInputCard({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final String value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                icon: const Icon(Icons.remove, size: 15),
                onPressed: onDecrement,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  value,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                icon: const Icon(Icons.add, size: 15),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderOptionCard extends StatelessWidget {
  const _GenderOptionCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.bloodRed;
    final borderColor = isSelected
        ? activeColor
        : (isDark ? AppColors.cardBorder : AppColors.lightCardBorder);
    final bgColor = isSelected
        ? activeColor.withValues(alpha: 0.18)
        : (isDark ? AppColors.cardSurfaceElevated : AppColors.lightSurfaceElevated);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.textPrimary : AppColors.bloodRed)
                      : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthCheckbox extends StatelessWidget {
  const _HealthCheckbox({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          fontSize: 13,
        ),
      ),
      value: value,
      activeColor: AppColors.bloodRed,
      onChanged: onChanged,
    );
  }
}
