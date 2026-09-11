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
  });
}
