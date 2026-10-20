import 'package:damla/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeController Testleri', () {
    test('Varsayılan tema modu dark olmalı ve toggleTheme ile light moda geçmeli', () {
      final controller = ThemeController.instance;
      controller.setThemeMode(ThemeMode.dark);

      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);

      controller.toggleTheme();
      expect(controller.themeMode, ThemeMode.light);
      expect(controller.isDarkMode, isFalse);

      controller.toggleTheme();
      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);
    });

    test('setThemeMode doğrudan tema atamalı', () {
      final controller = ThemeController.instance;

      controller.setThemeMode(ThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);

      controller.setThemeMode(ThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);
    });
  });
}
