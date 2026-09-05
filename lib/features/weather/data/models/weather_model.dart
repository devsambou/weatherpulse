import '../../domain/entities/weather.dart';

/// Le Model sait parser le JSON ; l'Entity du domain ne le sait pas
class WeatherModel extends Weather {
  const WeatherModel({
    required super.cityName,
    required super.temperature,
    required super.feelsLike,
    required super.description,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
    required super.fetchedAt,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': cityName,
        'main': {
          'temp': temperature,
          'feels_like': feelsLike,
          'humidity': humidity,
        },
        'weather': [
          {'description': description, 'icon': iconCode}
        ],
        'wind': {'speed': windSpeed},
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  /// Reconstruit un WeatherModel depuis le cache local (Hive)
  factory WeatherModel.fromCacheJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      fetchedAt: DateTime.parse(json['fetchedAt']),
    );
  }
}
