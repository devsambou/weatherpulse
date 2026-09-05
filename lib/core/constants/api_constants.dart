class ApiConstants {
  // ⚠️ Ne jamais commit la clé en dur : passer par --dart-define en CI et en local
  static const String apiKey = String.fromEnvironment('OPENWEATHER_API_KEY');
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  static String currentWeatherByCity(String city) =>
      '$baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=fr';

  static String currentWeatherByCoords(double lat, double lon) =>
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=fr';

  static String forecastByCity(String city) =>
      '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=fr';
}

class CacheConstants {
  static const String weatherBoxName = 'weather_cache_box';
  static const Duration cacheValidity = Duration(minutes: 30);
}
