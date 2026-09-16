import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/data/models/forecast_hour_model.dart';

void main() {
  group('ForecastHourModel', () {
    final tEntry = {
      'dt': 1721300000,
      'dt_txt': '2024-07-18 12:00:00',
      'main': {'temp': 28.5, 'feels_like': 30.1, 'humidity': 68},
      'weather': [
        {'description': 'ciel dégagé', 'icon': '01d'},
      ],
      'wind': {'speed': 4.2},
      'pop': 0.25,
      'rain': {'3h': 0.8},
    };

    test('fromJson parse correctement un élément de tranche horaire', () {
      final model = ForecastHourModel.fromJson(tEntry);

      expect(model.temperature, 28.5);
      expect(model.feelsLike, 30.1);
      expect(model.description, 'ciel dégagé');
      expect(model.iconCode, '01d');
      expect(model.pop, 0.25);
      expect(model.rainVolume, 0.8);
      expect(model.windSpeed, 4.2);
      expect(model.humidity, 68);
      expect(model.dateTime, isA<DateTime>());
    });

    test('fromForecastJson parse la liste complète de tranches', () {
      final forecastResponse = {
        'list': [tEntry, tEntry],
      };

      final models = ForecastHourModel.fromForecastJson(forecastResponse);

      expect(models.length, 2);
      expect(models[0].temperature, 28.5);
      expect(models[1].pop, 0.25);
    });

    test('toJson et fromCacheJson sérialisent et désérialisent sans perte', () {
      final model = ForecastHourModel.fromJson(tEntry);
      final json = model.toJson();
      final fromCache = ForecastHourModel.fromCacheJson(json);

      expect(fromCache.temperature, model.temperature);
      expect(fromCache.feelsLike, model.feelsLike);
      expect(fromCache.description, model.description);
      expect(fromCache.iconCode, model.iconCode);
      expect(fromCache.pop, model.pop);
      expect(fromCache.rainVolume, model.rainVolume);
      expect(fromCache.windSpeed, model.windSpeed);
      expect(fromCache.humidity, model.humidity);
    });
  });
}
