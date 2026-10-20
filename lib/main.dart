import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/home/view/main_screen.dart';

void main() {
  runApp(const DamlaApp());
}

/// Damla Kan Bağışı ve İyileşme Takip Uygulaması Kök Widget'ı
class DamlaApp extends StatelessWidget {
  const DamlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Damla',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}
