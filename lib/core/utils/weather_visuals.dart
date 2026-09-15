import 'package:flutter/material.dart';

import '../theme/weather_palette.dart';

/// Traduction des codes icône OpenWeather en visuels : emoji de repli et
/// dégradé de fond plein écran cohérent avec la condition (et le jour/nuit / mode sombre).
///
/// Table de correspondance : https://openweathermap.org/weather-conditions
class WeatherVisuals {
  WeatherVisuals._();

  static bool isNight(String iconCode) => iconCode.endsWith('n');

  /// Emoji utilisé si l'image officielle OpenWeather n'est pas disponible.
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
