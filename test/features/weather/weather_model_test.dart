import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/data/models/weather_model.dart';

void main() {
  group('WeatherModel', () {
    // JSON représentatif d'une vraie réponse OpenWeather /weather
    const tWeatherJson = {
      'name': 'Dakar',
      'main': {'temp': 29.5, 'feels_like': 31.0, 'humidity': 70},
      'weather': [
        {'description': 'ciel dégagé', 'icon': '01d'},
      ],
      'wind': {'speed': 3.2},
    };

    test('fromJson parse correctement une réponse OpenWeather', () {
      final json = {
        'name': 'Dakar',
        'main': {'temp': 29.5, 'feels_like': 31.0, 'humidity': 70},
        'weather': [
          {'description': 'ciel dégagé', 'icon': '01d'},
        ],
        'wind': {'speed': 3.2},
      };
      final model = WeatherModel.fromJson(json);

      expect(model.cityName, 'Dakar');
      expect(model.temperature, 29.5);
      expect(model.feelsLike, 31.0);
      expect(model.humidity, 70);
      expect(model.description, 'ciel dégagé');
      expect(model.iconCode, '01d');
      expect(model.windSpeed, 3.2);
    });

    test('fromJson fixe fetchedAt à DateTime.now() approximativement', () {
      final before = DateTime.now();
      final model = WeatherModel.fromJson(tWeatherJson);
      final after = DateTime.now();

      expect(
        model.fetchedAt.isAfter(before) || model.fetchedAt == before,
        isTrue,
      );
      expect(
        model.fetchedAt.isBefore(after) || model.fetchedAt == after,
        isTrue,
      );
    });

    test('toJson produit la structure JSON attendue', () {
      final model = WeatherModel.fromJson(tWeatherJson);
      final json = model.toJson();

      expect(json['name'], 'Dakar');
      expect(json['main']['temp'], 29.5);
      expect(json['main']['humidity'], 70);
      expect(json['weather'][0]['icon'], '01d');
    });

    test('fromCacheJson reconstruit correctement depuis le cache', () {
      final original = WeatherModel.fromJson(tWeatherJson);
      final cacheJson = original.toJson();
      final fromCache = WeatherModel.fromCacheJson(cacheJson);

      expect(fromCache.cityName, original.cityName);
      expect(fromCache.temperature, original.temperature);
      expect(fromCache.humidity, original.humidity);
      expect(fromCache.iconCode, original.iconCode);
    });

    test('température négative est parsée correctement', () {
      final coldJson = {
        'name': 'Reykjavik',
        'main': {'temp': -15.3, 'feels_like': -22.0, 'humidity': 85},
        'weather': [
          {'description': 'neige', 'icon': '13d'},
        ],
        'wind': {'speed': 8.5},
      };
      final model = WeatherModel.fromJson(coldJson);
      expect(model.temperature, -15.3);
      expect(model.feelsLike, -22.0);
    });

    test('température entière (int) est convertie en double', () {
      final intTempJson = {
        'name': 'Paris',
        'main': {'temp': 20, 'feels_like': 19, 'humidity': 60},
        'weather': [
          {'description': 'nuageux', 'icon': '03d'},
        ],
        'wind': {'speed': 5},
      };
      final model = WeatherModel.fromJson(intTempJson);
      expect(model.temperature, isA<double>());
      expect(model.temperature, 20.0);
    });

    test(
      'parse tous les champs enrichis d\'une réponse complète OpenWeather',
      () {
        final fullJson = {
          'name': 'Dakar',
          'main': {
            'temp': 29.5,
            'feels_like': 31.0,
            'temp_min': 28.0,
            'temp_max': 31.5,
            'pressure': 1014,
            'humidity': 70,
          },
          'weather': [
            {'description': 'ciel dégagé', 'icon': '01d'},
          ],
          'wind': {'speed': 3.2, 'deg': 240},
          'clouds': {'all': 15},
          'visibility': 10000,
          'sys': {'sunrise': 1721278800, 'sunset': 1721323200},
          'rain': {'1h': 1.8},
        };

        final model = WeatherModel.fromJson(fullJson);

        expect(model.cityName, 'Dakar');
        expect(model.windDegree, 240);
        expect(model.cloudiness, 15);
        expect(model.pressure, 1014);
        expect(model.visibility, 10000);
        expect(model.rainVolume, 1.8);
        expect(model.tempMin, 28.0);
        expect(model.tempMax, 31.5);
        expect(model.sunrise, isA<DateTime>());
        expect(model.sunset, isA<DateTime>());
      },
    );

    test(
      'gère l\'absence des champs optionnels (pluie, vent deg) avec valeurs par défaut',
      () {
        final partialJson = {
          'name': 'Thiès',
          'main': {'temp': 27.0, 'feels_like': 28.0, 'humidity': 65},
          'weather': [
            {'description': 'soleil', 'icon': '01d'},
          ],
          'wind': {'speed': 2.5},
        };

        final model = WeatherModel.fromJson(partialJson);

        expect(model.rainVolume, isNull);
        expect(model.windDegree, 0);
        expect(model.cloudiness, 0);
        expect(model.pressure, 1013);
        expect(model.visibility, 10000);
        expect(model.tempMin, 27.0);
        expect(model.tempMax, 27.0);
      },
    );

    test('sauvegarde et restaure tous les champs enrichis via cache', () {
      final fullJson = {
        'name': 'Dakar',
        'main': {
          'temp': 29.5,
          'feels_like': 31.0,
          'temp_min': 28.0,
          'temp_max': 31.5,
          'pressure': 1014,
          'humidity': 70,
        },
        'weather': [
          {'description': 'ciel dégagé', 'icon': '01d'},
        ],
        'wind': {'speed': 3.2, 'deg': 240},
        'clouds': {'all': 15},
        'visibility': 10000,
        'sys': {'sunrise': 1721278800, 'sunset': 1721323200},
        'rain': {'1h': 1.8},
      };

      final original = WeatherModel.fromJson(fullJson);
      final cacheJson = original.toJson();
      final fromCache = WeatherModel.fromCacheJson(cacheJson);

      expect(fromCache.cityName, original.cityName);
      expect(fromCache.windDegree, 240);
      expect(fromCache.cloudiness, 15);
      expect(fromCache.pressure, 1014);
      expect(fromCache.visibility, 10000);
      expect(fromCache.rainVolume, 1.8);
      expect(fromCache.tempMin, 28.0);
      expect(fromCache.tempMax, 31.5);
    });
  });
}
