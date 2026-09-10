import 'package:flutter/material.dart';

/// Traduction des codes icône OpenWeather en visuels : emoji de repli et
/// dégradé de fond plein écran cohérent avec la condition (et le jour/nuit).
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
  static List<Color> backgroundGradient(String? iconCode) {
    if (iconCode == null) {
      return const [Color(0xFF2E5C9E), Color(0xFF4A82C4), Color(0xFF83B4E4)];
    }
    final night = isNight(iconCode);
    switch (_prefix(iconCode)) {
      case '01': // ciel clair
        return night
            ? const [Color(0xFF0B1026), Color(0xFF1B2450), Color(0xFF35407A)]
            : const [Color(0xFF2E6FD6), Color(0xFF4A90E2), Color(0xFF8FC0EF)];
      case '02': // quelques nuages
      case '03':
      case '04': // couvert
        return night
            ? const [Color(0xFF1A222E), Color(0xFF33404F), Color(0xFF505F70)]
            : const [Color(0xFF4B6377), Color(0xFF74909F), Color(0xFFA9BEC8)];
      case '09': // averses
      case '10': // pluie
      case '11': // orage
        return night
            ? const [Color(0xFF10161F), Color(0xFF263340), Color(0xFF3C4C5C)]
            : const [Color(0xFF37474F), Color(0xFF54656F), Color(0xFF78909C)];
      case '13': // neige
        return const [Color(0xFF5B6B78), Color(0xFF8FA3B0), Color(0xFFC7D5DE)];
      case '50': // brume
        return const [Color(0xFF4A4F54), Color(0xFF6E7479), Color(0xFF9AA0A5)];
      default:
        return const [Color(0xFF2E6FD6), Color(0xFF4A90E2), Color(0xFF8FC0EF)];
    }
  }

  static String _prefix(String iconCode) =>
      iconCode.length >= 2 ? iconCode.substring(0, 2) : iconCode;
}
