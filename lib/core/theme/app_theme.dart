import 'package:flutter/material.dart';

/// Thème unique de l'application (le mode sombre est hors périmètre, CDC §2.2).
///
/// L'écran principal peint lui-même son dégradé plein écran ; le thème ne fixe
/// donc que les fondamentaux Material 3.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E6FD6)),
      scaffoldBackgroundColor: const Color(0xFF2E6FD6),
    );
  }
}
