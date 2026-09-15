import 'package:flutter/material.dart';

import '../../features/weather/domain/entities/weather.dart';

/// Conditions météo normalisées pour la sélection de la palette visuelle.
enum WeatherCondition {
  clear,
  clouds,
  rain,
  storm,
  snow,
  unknown;

  /// Dérive la [WeatherCondition] depuis un code icône OpenWeather (ex: '01d', '04n').
  static WeatherCondition fromIconCode(String? iconCode) {
    if (iconCode == null || iconCode.isEmpty) return WeatherCondition.unknown;
    final prefix = iconCode.length >= 2 ? iconCode.substring(0, 2) : iconCode;
    switch (prefix) {
      case '01':
        return WeatherCondition.clear;
      case '02':
      case '03':
      case '04':
      case '50': // Brouillard / brume rattaché aux nuages/couvert
        return WeatherCondition.clouds;
      case '09':
      case '10':
        return WeatherCondition.rain;
      case '11':
        return WeatherCondition.storm;
      case '13':
        return WeatherCondition.snow;
      default:
        return WeatherCondition.unknown;
    }
  }

  /// Dérive la [WeatherCondition] directement depuis l'entité [Weather].
  static WeatherCondition fromWeather(Weather? weather) {
    if (weather == null) return WeatherCondition.unknown;
    return fromIconCode(weather.iconCode);
  }

  /// Libellé lisible en français.
  String get label {
    switch (this) {
      case WeatherCondition.clear:
        return 'Ensoleillé / Dégagé';
      case WeatherCondition.clouds:
        return 'Nuageux';
      case WeatherCondition.rain:
        return 'Pluvieux';
      case WeatherCondition.storm:
        return 'Orageux';
      case WeatherCondition.snow:
        return 'Neigeux';
      case WeatherCondition.unknown:
        return 'Indéterminé';
    }
  }
}

/// Palette de couleurs adaptative selon la météo et le mode clair/sombre.
class WeatherPalette {
  final WeatherCondition condition;
  final bool isDark;
  final Color primary;
  final List<Color> backgroundGradient;
  final Color cardBackground;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;

  const WeatherPalette({
    required this.condition,
    required this.isDark,
    required this.primary,
    required this.backgroundGradient,
    required this.cardBackground,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  /// Retourne la palette adaptée à la condition météo et au mode (clair/sombre).
  factory WeatherPalette.get(
    WeatherCondition condition, {
    required bool isDark,
  }) {
    switch (condition) {
      case WeatherCondition.clear:
        return isDark
            ? const WeatherPalette(
                condition: WeatherCondition.clear,
                isDark: true,
                primary: Color(0xFF4A90E2),
                backgroundGradient: [
                  Color(0xFF0B1026),
                  Color(0xFF1B2450),
                  Color(0xFF2B366E),
                ],
                cardBackground: Color(0x9E131B33),
                cardBorder: Color(0x594A5C94),
                textPrimary: Colors.white,
                textSecondary: Color(0xB3FFFFFF),
                accentColor: Color(0xFFFFE082),
              )
            : const WeatherPalette(
                condition: WeatherCondition.clear,
                isDark: false,
                primary: Color(0xFF2E6FD6),
                backgroundGradient: [
                  Color(0xFF2E6FD6),
                  Color(0xFF4A90E2),
                  Color(0xFF8FC0EF),
                ],
                cardBackground: Color(0x2EFFFFFF),
                cardBorder: Color(0x47FFFFFF),
                textPrimary: Colors.white,
                textSecondary: Color(0xBFFFFFFF),
                accentColor: Color(0xFFFFD54F),
              );

      case WeatherCondition.clouds:
        return isDark
            ? const WeatherPalette(
                condition: WeatherCondition.clouds,
                isDark: true,
                primary: Color(0xFF78909C),
                backgroundGradient: [
                  Color(0xFF151C24),
                  Color(0xFF25303D),
                  Color(0xFF384656),
                ],
                cardBackground: Color(0xB31C242E),
                cardBorder: Color(0x594C5D6F),
                textPrimary: Colors.white,
                textSecondary: Color(0xB3FFFFFF),
                accentColor: Color(0xFFB0BEC5),
              )
            : const WeatherPalette(
                condition: WeatherCondition.clouds,
                isDark: false,
                primary: Color(0xFF4B6377),
                backgroundGradient: [
                  Color(0xFF4B6377),
                  Color(0xFF678093),
                  Color(0xFF90A4AE),
                ],
                cardBackground: Color(0x2EFFFFFF),
                cardBorder: Color(0x42FFFFFF),
                textPrimary: Colors.white,
                textSecondary: Color(0xBFFFFFFF),
                accentColor: Color(0xFFECEFF1),
              );

      case WeatherCondition.rain:
        return isDark
            ? const WeatherPalette(
                condition: WeatherCondition.rain,
                isDark: true,
                primary: Color(0xFF607D8B),
                backgroundGradient: [
                  Color(0xFF10161F),
                  Color(0xFF1E2833),
                  Color(0xFF2E3D4C),
                ],
                cardBackground: Color(0xB3141C24),
                cardBorder: Color(0x593D4F61),
                textPrimary: Colors.white,
                textSecondary: Color(0xB3FFFFFF),
                accentColor: Color(0xFF40C4FF),
              )
            : const WeatherPalette(
                condition: WeatherCondition.rain,
                isDark: false,
                primary: Color(0xFF37474F),
                backgroundGradient: [
                  Color(0xFF37474F),
                  Color(0xFF455A64),
                  Color(0xFF607D8B),
                ],
                cardBackground: Color(0x29FFFFFF),
                cardBorder: Color(0x40FFFFFF),
                textPrimary: Colors.white,
                textSecondary: Color(0xBFFFFFFF),
                accentColor: Color(0xFF80D8FF),
              );

      case WeatherCondition.storm:
        return isDark
            ? const WeatherPalette(
                condition: WeatherCondition.storm,
                isDark: true,
                primary: Color(0xFF5C6BC0),
                backgroundGradient: [
                  Color(0xFF0F1216),
                  Color(0xFF1A1F26),
                  Color(0xFF2A313C),
                ],
                cardBackground: Color(0xBF12161D),
                cardBorder: Color(0x59475263),
                textPrimary: Colors.white,
                textSecondary: Color(0xB3FFFFFF),
                accentColor: Color(0xFFFFEA00),
              )
            : const WeatherPalette(
                condition: WeatherCondition.storm,
                isDark: false,
                primary: Color(0xFF263238),
                backgroundGradient: [
                  Color(0xFF263238),
                  Color(0xFF37474F),
                  Color(0xFF455A64),
                ],
                cardBackground: Color(0x29FFFFFF),
                cardBorder: Color(0x40FFFFFF),
                textPrimary: Colors.white,
                textSecondary: Color(0xBFFFFFFF),
                accentColor: Color(0xFFFFD700),
              );

      case WeatherCondition.snow:
        return isDark
            ? const WeatherPalette(
                condition: WeatherCondition.snow,
                isDark: true,
                primary: Color(0xFF80DEEA),
                backgroundGradient: [
                  Color(0xFF161E28),
                  Color(0xFF24303F),
                  Color(0xFF37495E),
                ],
                cardBackground: Color(0xB319222E),
                cardBorder: Color(0x59465970),
                textPrimary: Colors.white,
                textSecondary: Color(0xB3FFFFFF),
                accentColor: Color(0xFF80DEEA),
              )
            : const WeatherPalette(
                condition: WeatherCondition.snow,
                isDark: false,
                primary: Color(0xFF546E7A),
                backgroundGradient: [
                  Color(0xFF546E7A),
                  Color(0xFF78909C),
                  Color(0xFFB0BEC5),
                ],
                cardBackground: Color(0x38FFFFFF),
                cardBorder: Color(0x59FFFFFF),
                textPrimary: Colors.white,
                textSecondary: Color(0xBFFFFFFF),
                accentColor: Color(0xFFE0F7FA),
              );

      case WeatherCondition.unknown:
        return isDark
            ? const WeatherPalette(
                condition: WeatherCondition.unknown,
                isDark: true,
                primary: Color(0xFF4A90E2),
                backgroundGradient: [
                  Color(0xFF101726),
                  Color(0xFF1E2840),
                  Color(0xFF2F3C5E),
                ],
                cardBackground: Color(0xB3141B2E),
                cardBorder: Color(0x5944547B),
                textPrimary: Colors.white,
                textSecondary: Color(0xB3FFFFFF),
                accentColor: Color(0xFF64B5F6),
              )
            : const WeatherPalette(
                condition: WeatherCondition.unknown,
                isDark: false,
                primary: Color(0xFF2E5C9E),
                backgroundGradient: [
                  Color(0xFF2E5C9E),
                  Color(0xFF4A82C4),
                  Color(0xFF83B4E4),
                ],
                cardBackground: Color(0x2EFFFFFF),
                cardBorder: Color(0x47FFFFFF),
                textPrimary: Colors.white,
                textSecondary: Color(0xBFFFFFFF),
                accentColor: Color(0xFF90CAF9),
              );
    }
  }

  /// Dérive commodément la palette à partir d'un [Weather] et du mode [isDark].
  factory WeatherPalette.fromWeather(Weather? weather, {required bool isDark}) {
    final condition = WeatherCondition.fromWeather(weather);
    return WeatherPalette.get(condition, isDark: isDark);
  }
}
