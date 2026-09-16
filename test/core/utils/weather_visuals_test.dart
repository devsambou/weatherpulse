import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/utils/weather_visuals.dart';

void main() {
  group('WeatherVisuals.isNight', () {
    test('retourne true pour les codes nocturnes se terminant par "n"', () {
      expect(WeatherVisuals.isNight('01n'), isTrue);
      expect(WeatherVisuals.isNight('04n'), isTrue);
    });

    test('retourne false pour les codes diurnes se terminant par "d"', () {
      expect(WeatherVisuals.isNight('01d'), isFalse);
      expect(WeatherVisuals.isNight('10d'), isFalse);
    });
  });

  group('WeatherVisuals.icon', () {
    test('retourne wb_sunny_rounded pour "01d" (ciel dégagé jour)', () {
      expect(WeatherVisuals.icon('01d'), Icons.wb_sunny_rounded);
    });

    test('retourne nightlight_round pour "01n" (ciel dégagé nuit)', () {
      expect(WeatherVisuals.icon('01n'), Icons.nightlight_round);
    });

    test('retourne cloud_queue_rounded pour "02d" (quelques nuages)', () {
      expect(WeatherVisuals.icon('02d'), Icons.cloud_queue_rounded);
    });

    test('retourne cloud_outlined pour "03d" (nuages épars)', () {
      expect(WeatherVisuals.icon('03d'), Icons.cloud_outlined);
    });

    test('retourne cloud_rounded pour "04d" (nuages fragmentés)', () {
      expect(WeatherVisuals.icon('04d'), Icons.cloud_rounded);
    });

    test('retourne grain_rounded pour "09d" (pluie en averses)', () {
      expect(WeatherVisuals.icon('09d'), Icons.grain_rounded);
    });

    test('retourne water_drop_rounded pour "10d" (pluie)', () {
      expect(WeatherVisuals.icon('10d'), Icons.water_drop_rounded);
    });

    test('retourne thunderstorm_rounded pour "11d" (orage)', () {
      expect(WeatherVisuals.icon('11d'), Icons.thunderstorm_rounded);
    });

    test('retourne ac_unit_rounded pour "13d" (neige)', () {
      expect(WeatherVisuals.icon('13d'), Icons.ac_unit_rounded);
    });

    test('retourne foggy pour "50d" (brouillard)', () {
      expect(WeatherVisuals.icon('50d'), Icons.foggy);
    });

    test('retourne device_thermostat_rounded pour un code inconnu', () {
      expect(WeatherVisuals.icon('99d'), Icons.device_thermostat_rounded);
      expect(WeatherVisuals.icon(''), Icons.device_thermostat_rounded);
    });
  });

  group('WeatherVisuals.emoji', () {
    test('retourne ☀️ pour "01d"', () {
      expect(WeatherVisuals.emoji('01d'), '☀️');
    });

    test('retourne 🌙 pour "01n"', () {
      expect(WeatherVisuals.emoji('01n'), '🌙');
    });

    test('retourne 🌤️ pour "02d"', () {
      expect(WeatherVisuals.emoji('02d'), '🌤️');
    });

    test('retourne ⛅ pour "03d"', () {
      expect(WeatherVisuals.emoji('03d'), '⛅');
    });

    test('retourne ☁️ pour "04d"', () {
      expect(WeatherVisuals.emoji('04d'), '☁️');
    });

    test('retourne 🌧️ pour "09d"', () {
      expect(WeatherVisuals.emoji('09d'), '🌧️');
    });

    test('retourne 🌦️ pour "10d"', () {
      expect(WeatherVisuals.emoji('10d'), '🌦️');
    });

    test('retourne ⛈️ pour "11d"', () {
      expect(WeatherVisuals.emoji('11d'), '⛈️');
    });

    test('retourne ❄️ pour "13d"', () {
      expect(WeatherVisuals.emoji('13d'), '❄️');
    });

    test('retourne 🌫️ pour "50d"', () {
      expect(WeatherVisuals.emoji('50d'), '🌫️');
    });

    test('retourne 🌡️ pour un code inconnu', () {
      expect(WeatherVisuals.emoji('99d'), '🌡️');
    });
  });

  group('WeatherVisuals.backgroundGradient', () {
    test('retourne une liste non vide pour null (état neutre)', () {
      final gradient = WeatherVisuals.backgroundGradient(null);
      expect(gradient, isNotEmpty);
    });

    test('retourne un dégradé pour "01d" (ensoleillé)', () {
      final gradient = WeatherVisuals.backgroundGradient('01d');
      expect(gradient.length, greaterThanOrEqualTo(2));
      for (final c in gradient) {
        expect(c, isA<Color>());
      }
    });

    test('retourne un dégradé nocturne si isDark=true', () {
      final lightGradient = WeatherVisuals.backgroundGradient(
        '01d',
        isDark: false,
      );
      final darkGradient = WeatherVisuals.backgroundGradient(
        '01d',
        isDark: true,
      );
      // Les dégradés jour/nuit doivent être différents
      expect(lightGradient, isNot(equals(darkGradient)));
    });
  });
}
