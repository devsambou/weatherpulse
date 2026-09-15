import 'package:flutter/material.dart';

/// Thème clair et sombre de l'application Material 3.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E6FD6),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFF2E6FD6),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B2450),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1424),
    );
  }
}

/// Palette de couleurs et styles pour les cartes glassmorphism et composants météo
class WeatherPalette {
  WeatherPalette._();

  static const Color accent = Color(0xFF2E6FD6);

  static Color glassBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.black.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.16);
  }

  static Color glassBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.22);
  }

  static Color textPrimary(BuildContext context) => Colors.white;

  static Color textSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.75);
  }

  static Color searchFieldBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.black.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.18);
  }
}
