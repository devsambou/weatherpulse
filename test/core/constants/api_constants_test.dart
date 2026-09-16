import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/constants/api_constants.dart';
import '../../helpers/test_environment.dart';

void main() {
  setUpAll(setupTestEnvironment);

  group('ApiConstants', () {
    test('génère les URLs correctes pour météo et prévisions', () {
      expect(ApiConstants.baseUrl, 'https://api.openweathermap.org/data/2.5');

      final cityUrl = ApiConstants.currentWeatherByCity('Paris');
      expect(cityUrl, contains('/weather?q=Paris'));
      expect(cityUrl, contains('units=metric'));
      expect(cityUrl, contains('lang=fr'));

      final coordsUrl = ApiConstants.currentWeatherByCoords(48.8566, 2.3522);
      expect(coordsUrl, contains('/weather?lat=48.8566&lon=2.3522'));

      final forecastUrl = ApiConstants.forecastByCity('Paris');
      expect(forecastUrl, contains('/forecast?q=Paris'));
    });

    test('constantes de cache, favoris et settings', () {
      expect(CacheConstants.weatherBoxName, 'weather_cache_box');
      expect(CacheConstants.cacheValidity.inMinutes, 30);
      expect(FavoritesConstants.boxName, 'favorites_box');
      expect(SettingsConstants.boxName, 'settings_box');
      expect(SettingsConstants.themeModeKey, 'theme_mode');
    });
  });
}
