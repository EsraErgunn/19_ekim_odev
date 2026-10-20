import 'package:flutter/material.dart';

/// Damla uygulaması "Klinik Gece" tasarım sistemine ait renk paleti.
class AppColors {
  const AppColors._();

  // Koyu Tema Zemin & Yüzey Tonları (Obsidyen & Derin Lacivert)
  static const Color obsidianBackground = Color(0xFF0B101B);
  static const Color darkNavySurface = Color(0xFF111827);
  static const Color cardSurface = Color(0xFF161F30);
  static const Color cardSurfaceElevated = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF2E3D56);

  // Açık Tema Zemin & Yüzey Tonları
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightCardBorder = Color(0xFFE2E8F0);

  // Vurgu & Kan Kırmızısı Tonları
  static const Color bloodRed = Color(0xFFE53950);
  static const Color bloodRedDark = Color(0xFF8B0018);
  static const Color bloodRedLight = Color(0xFFFF536A);
  static const Color bloodRedGlow = Color(0xFFFF8595);
  static const Color bloodRedTrack = Color(0x2EE53950);

  // İyileşme & Yenilenme (Turkuaz - Yeşil)
  static const Color recoveryTeal = Color(0xFF00C9A7);
  static const Color recoveryTealDark = Color(0xFF00897B);
  static const Color recoveryTealLight = Color(0xFF64FFDA);

  // Başarı & Ödül (Altın - Amber)
  static const Color gold = Color(0xFFFFD166);
  static const Color goldDark = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFFE89E);

  // Durum & İkaz Tonları
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF38BDF8);

  // Tüp & Şeffaf Plastik Tonları
  static const Color tubeSilicone = Color(0x33CBD5E1);
  static const Color tubeBorder = Color(0x5594A3B8);
  static const Color tubeHighlight = Color(0x88FFFFFF);

  // Tipografi Koyu Tema Tonları
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Tipografi Açık Tema Tonları
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
}
