import 'package:flutter/material.dart';

/// Configuration des thèmes clair et sombre de l'application Material 3.
///
/// L'écran principal peint lui-même un dégradé dynamique selon la météo
/// (voir core/theme/weather_palette.dart) ; ce fichier fixe uniquement les
/// fondamentaux Material 3 (ColorScheme, AppBar, Card) pour l'ensemble des
/// pages et widgets.
class AppTheme {
  AppTheme._();

  static const _primarySeed = Color(0xFF2E6FD6);

  static const _emojiFallback = [
    'Segoe UI Emoji',
    'Apple Color Emoji',
    'Noto Color Emoji',
  ];

  /// Thème clair de l'application
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamilyFallback: _emojiFallback,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primarySeed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _primarySeed,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Thème sombre de l'application
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamilyFallback: _emojiFallback,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primarySeed,
        brightness: Brightness.dark,
        surface: const Color(0xFF141B26),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1722),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1B2433),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Styles utilitaires pour les surfaces "verre dépoli" (glassmorphism)
/// qui ne dépendent pas de la condition météo — uniquement du mode clair/sombre.
///
/// ⚠️ Ne pas confondre avec [WeatherPalette] dans
/// core/theme/weather_palette.dart, qui gère la palette complète
/// (dégradé de fond, couleurs de texte) SELON LA CONDITION MÉTÉO.
/// Ce renommage évite la collision de deux classes nommées `WeatherPalette`.
class GlassStyles {
  GlassStyles._();

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
