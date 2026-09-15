import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/theme/weather_palette.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';

void main() {
  group('WeatherCondition mapping', () {
    test(
      'fromIconCode mappe les codes OpenWeather vers la bonne condition',
      () {
        expect(WeatherCondition.fromIconCode('01d'), WeatherCondition.clear);
        expect(WeatherCondition.fromIconCode('01n'), WeatherCondition.clear);

        expect(WeatherCondition.fromIconCode('02d'), WeatherCondition.clouds);
        expect(WeatherCondition.fromIconCode('03n'), WeatherCondition.clouds);
        expect(WeatherCondition.fromIconCode('04d'), WeatherCondition.clouds);
        expect(WeatherCondition.fromIconCode('50d'), WeatherCondition.clouds);

        expect(WeatherCondition.fromIconCode('09d'), WeatherCondition.rain);
        expect(WeatherCondition.fromIconCode('10n'), WeatherCondition.rain);

        expect(WeatherCondition.fromIconCode('11d'), WeatherCondition.storm);
        expect(WeatherCondition.fromIconCode('13d'), WeatherCondition.snow);

        expect(WeatherCondition.fromIconCode(null), WeatherCondition.unknown);
        expect(WeatherCondition.fromIconCode(''), WeatherCondition.unknown);
        expect(WeatherCondition.fromIconCode('999'), WeatherCondition.unknown);
      },
    );

    test('fromWeather dérive la condition depuis une entité Weather', () {
      final weather = Weather(
        cityName: 'Dakar',
        temperature: 28.0,
        feelsLike: 30.0,
        description: 'ciel dégagé',
        iconCode: '01d',
        humidity: 65,
        windSpeed: 4.5,
        fetchedAt: DateTime.now(),
        sunrise: DateTime.now(),
        sunset: DateTime.now(),
      );

      expect(WeatherCondition.fromWeather(weather), WeatherCondition.clear);
      expect(WeatherCondition.fromWeather(null), WeatherCondition.unknown);
    });

    test('chaque condition a un libellé français lisible', () {
      for (final condition in WeatherCondition.values) {
        expect(condition.label.isNotEmpty, isTrue);
      }
    });
  });

  group('WeatherPalette', () {
    test(
      'WeatherPalette.get retourne une palette claire et sombre valide pour chaque condition',
      () {
        for (final condition in WeatherCondition.values) {
          final lightPalette = WeatherPalette.get(condition, isDark: false);
          final darkPalette = WeatherPalette.get(condition, isDark: true);

          expect(lightPalette.isDark, isFalse);
          expect(darkPalette.isDark, isTrue);

          expect(
            lightPalette.backgroundGradient.length,
            greaterThanOrEqualTo(2),
          );
          expect(
            darkPalette.backgroundGradient.length,
            greaterThanOrEqualTo(2),
          );

          expect(lightPalette.textPrimary, Colors.white);
          expect(darkPalette.textPrimary, Colors.white);

          expect(lightPalette.cardBackground.a, greaterThan(0));
          expect(darkPalette.cardBackground.a, greaterThan(0));
        }
      },
    );

    test('WeatherPalette.fromWeather adapte les couleurs et dégradés', () {
      final weather = Weather(
        cityName: 'Paris',
        temperature: 15.0,
        feelsLike: 14.0,
        description: 'pluie modérée',
        iconCode: '10d',
        humidity: 80,
        windSpeed: 5.0,
        fetchedAt: DateTime.now(),
        sunrise: DateTime.now(),
        sunset: DateTime.now(),
      );

      final palette = WeatherPalette.fromWeather(weather, isDark: true);
      expect(palette.condition, WeatherCondition.rain);
      expect(palette.isDark, isTrue);
      expect(palette.primary, const Color(0xFF607D8B));
    });
  });
}
