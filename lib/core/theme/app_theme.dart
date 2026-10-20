import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Damla uygulaması tema konfigürasyonu (Koyu ve Aydınlık Tema Desteği).
class AppTheme {
  const AppTheme._();

  /// Koyu Tema (Klinik Gece)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidianBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.bloodRed,
        onPrimary: Colors.white,
        secondary: AppColors.recoveryTeal,
        onSecondary: Colors.black,
        surface: AppColors.cardSurface,
        onSurface: AppColors.textPrimary,
        tertiary: AppColors.gold,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkNavySurface,
        indicatorColor: AppColors.bloodRed.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.bloodRedLight
                : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.bloodRedLight
                : AppColors.textSecondary,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bloodRed,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        labelSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Aydınlık Tema (Klinik Gündüz)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.bloodRed,
        onPrimary: Colors.white,
        secondary: AppColors.recoveryTealDark,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        tertiary: AppColors.goldDark,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.bloodRed.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.bloodRed
                : AppColors.lightTextSecondary,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.bloodRed
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bloodRed,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
        ),
        labelSmall: TextStyle(
          color: AppColors.lightTextMuted,
          fontSize: 12,
        ),
      ),
    );
  }
}
