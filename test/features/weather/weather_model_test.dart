import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/data/models/weather_model.dart';

void main() {
  group('WeatherModel', () {
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
      expect(model.humidity, 70);
      expect(model.description, 'ciel dégagé');
    });
  });
}
