import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/emergency_requests_controller.dart';
import '../models/emergency_request.dart';
import '../widget/emergency_request_card.dart';

/// Canlı Acil Kan Talepleri Sayfası
class EmergencyRequestsPage extends StatefulWidget {
  const EmergencyRequestsPage({super.key, this.controller});

  final EmergencyRequestsController? controller;

  @override
  State<EmergencyRequestsPage> createState() => _EmergencyRequestsPageState();
}

class _EmergencyRequestsPageState extends State<EmergencyRequestsPage> {
  late final EmergencyRequestsController _controller;
  bool _ownsController = false;

  final List<String> _bloodTypeFilters = [
    'Tümü',
    '0 Rh-',
    '0 Rh+',
    'A Rh-',
    'A Rh+',
    'B Rh-',
    'B Rh+',
    'AB Rh-',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = EmergencyRequestsController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
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
      appBar: AppBar(
        title: const Text('Acil Kan Talepleri'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _buildBody(isDark),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    final requests = _controller.filteredRequests;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUrgencyBanner(isDark),
          const SizedBox(height: 16),
          _buildFilterScroll(isDark),
          const SizedBox(height: 14),
          for (final req in requests) ...[
            EmergencyRequestCard(
              request: req,
              onSupport: () => _handleSupport(req),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildUrgencyBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bloodRedDark.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bloodRed.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency_rounded, color: AppColors.bloodRedLight, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kritik Seviye Çağrısı (Simülasyon)',
                  style: TextStyle(color: AppColors.bloodRedLight, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${_controller.activeUrgentCount} hastanede acil ünite ihtiyacı bulunmaktadır.',
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

  Widget _buildFilterScroll(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _bloodTypeFilters.map((bt) {
          final isSelected = _controller.selectedBloodTypeFilter == bt;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(bt),
              selected: isSelected,
              onSelected: (_) => _controller.setBloodTypeFilter(bt),
              selectedColor: AppColors.bloodRed.withValues(alpha: 0.25),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleSupport(EmergencyBloodRequest req) {
    final success = _controller.supportRequest(req.id);
    if (!success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.recoveryTealDark,
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Teşekkürler! ${req.hospitalName} için 1 ünite bağış desteği kaydedildi.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
