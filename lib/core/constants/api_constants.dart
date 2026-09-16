import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // La clé est chargée depuis le fichier .env (non commité)
  // Voir .env.example pour le format attendu
  static String get apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
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

class FavoritesConstants {
  static const String boxName = 'favorites_box';
}

class SettingsConstants {
  static const String boxName = 'settings_box';
  static const String themeModeKey = 'theme_mode';
}
