import 'package:flutter/material.dart';

/// Damla uygulaması dinamik tema modu denetleyicisi (Koyu / Açık Tema).
class ThemeController {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  ThemeMode get themeMode => themeModeNotifier.value;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme() {
    themeModeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }
}
