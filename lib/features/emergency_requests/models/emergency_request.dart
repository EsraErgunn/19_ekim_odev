import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Aciliyet Seviyesi
enum RequestUrgency {
  critical('Hayati Acil (2 Saat)', AppColors.bloodRedLight, AppColors.bloodRedDark),
  high('Yüksek Öncelik (6 Saat)', AppColors.warningOrange, Color(0xFF7C2D12)),
  normal('Gereksinim (24 Saat)', AppColors.infoBlue, Color(0xFF0369A1));

  const RequestUrgency(this.label, this.color, this.backgroundColor);
  final String label;
  final Color color;
  final Color backgroundColor;
}

/// Acil Kan Talebi Modeli
class EmergencyBloodRequest {
  const EmergencyBloodRequest({
    required this.id,
    required this.hospitalName,
    required this.city,
    required this.bloodType,
    required this.patientInitials,
    required this.requiredUnits,
    required this.collectedUnits,
    required this.urgency,
    required this.diagnosis,
    required this.contactPhone,
    required this.createdAt,
  });

  final String id;
  final String hospitalName;
  final String city;
  final String bloodType;
  final String patientInitials;
  final int requiredUnits;
  final int collectedUnits;
  final RequestUrgency urgency;
  final String diagnosis;
  final String contactPhone;
  final DateTime createdAt;

  bool get isFulfilled => collectedUnits >= requiredUnits;
  double get progressRatio => (collectedUnits / requiredUnits).clamp(0.0, 1.0);

  EmergencyBloodRequest copyWith({int? collectedUnits}) {
    return EmergencyBloodRequest(
      id: id,
      hospitalName: hospitalName,
      city: city,
      bloodType: bloodType,
      patientInitials: patientInitials,
      requiredUnits: requiredUnits,
      collectedUnits: collectedUnits ?? this.collectedUnits,
      urgency: urgency,
      diagnosis: diagnosis,
      contactPhone: contactPhone,
      createdAt: createdAt,
    );
  }
}
