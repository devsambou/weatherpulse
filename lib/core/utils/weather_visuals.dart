import 'package:flutter/material.dart';

import '../theme/weather_palette.dart';

/// Traduction des codes icône OpenWeather en visuels : icône Material, emoji de repli et
/// dégradé de fond plein écran cohérent avec la condition (et le jour/nuit / mode sombre).
///
/// Table de correspondance : https://openweathermap.org/weather-conditions
class WeatherVisuals {
  WeatherVisuals._();

  static bool isNight(String iconCode) => iconCode.endsWith('n');

  /// Icône Material représentant la condition météo.
  ///
  /// Privilégié à [emoji] pour éviter la dépendance aux polices Noto/emoji
  /// absentes de certains environnements (Flutter Web, tests).
  static IconData icon(String iconCode) {
    switch (_prefix(iconCode)) {
      case '01':
        return isNight(iconCode)
            ? Icons.nightlight_round
            : Icons.wb_sunny_rounded;
      case '02':
        return Icons.cloud_queue_rounded;
      case '03':
        return Icons.cloud_outlined;
      case '04':
        return Icons.cloud_rounded;
      case '09':
        return Icons.grain_rounded;
      case '10':
        return Icons.water_drop_rounded;
      case '11':
        return Icons.thunderstorm_rounded;
      case '13':
        return Icons.ac_unit_rounded;
      case '50':
        return Icons.foggy;
      default:
        return Icons.device_thermostat_rounded;
    }
  }

  /// Emoji utilisé comme repli textuel (ex. logs, accessibilité, export).
  static String emoji(String iconCode) {
    switch (_prefix(iconCode)) {
      case '01':
        return isNight(iconCode) ? '🌙' : '☀️';
      case '02':
        return '🌤️';
      case '03':
        return '⛅';
      case '04':
        return '☁️';
      case '09':
        return '🌧️';
      case '10':
        return '🌦️';
      case '11':
        return '⛈️';
      case '13':
        return '❄️';
      case '50':
        return '🌫️';
      default:
        return '🌡️';
    }
  }

  /// Dégradé vertical (haut → bas) du fond de l'écran principal.
  /// [iconCode] `null` → dégradé neutre (états chargement / vide / erreur).
  /// [isDark] permet d'imposer le mode sombre si spécifié, sinon détecte automatiquement
  /// si l'icône est nocturne.
  static List<Color> backgroundGradient(String? iconCode, {bool? isDark}) {
    final condition = WeatherCondition.fromIconCode(iconCode);
    final effectiveDark = isDark ?? (iconCode != null && isNight(iconCode));
    return WeatherPalette.get(
      condition,
      isDark: effectiveDark,
    ).backgroundGradient;
  }

  static String _prefix(String iconCode) =>
      iconCode.length >= 2 ? iconCode.substring(0, 2) : iconCode;
}
