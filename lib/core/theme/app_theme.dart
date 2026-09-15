import 'package:flutter/material.dart';

/// Configuration des thèmes clair et sombre de l'application.
///
/// L'écran principal peint lui-même un dégradé dynamique selon la météo ;
/// le thème fixe les fondamentaux Material 3 pour l'ensemble des pages et widgets.
class AppTheme {
  AppTheme._();

  static const _primarySeed = Color(0xFF2E6FD6);

  /// Thème clair de l'application
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamilyFallback: const [
        'Segoe UI Emoji',
        'Apple Color Emoji',
        'Noto Color Emoji',
      ],
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primarySeed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFF2E6FD6),
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
      fontFamilyFallback: const [
        'Segoe UI Emoji',
        'Apple Color Emoji',
        'Noto Color Emoji',
      ],
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
