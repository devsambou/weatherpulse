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
    super.windDegree,
    super.cloudiness,
    super.pressure,
    super.visibility,
    required super.sunrise,
    required super.sunset,
    super.rainVolume,
    super.tempMin,
    super.tempMax,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = (json['main'] as Map<String, dynamic>?) ?? {};
    final weatherList = (json['weather'] as List<dynamic>?) ?? [];
    final firstWeather = weatherList.isNotEmpty
        ? weatherList[0] as Map<String, dynamic>
        : <String, dynamic>{};
    final wind = (json['wind'] as Map<String, dynamic>?) ?? {};
    final clouds = (json['clouds'] as Map<String, dynamic>?) ?? {};
    final sys = (json['sys'] as Map<String, dynamic>?) ?? {};
    final rain = json['rain'] as Map<String, dynamic>?;

    final now = DateTime.now();
    final sunriseUnix = sys['sunrise'] as num?;
    final sunsetUnix = sys['sunset'] as num?;
    final sunrise = sunriseUnix != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (sunriseUnix * 1000).toInt(),
            isUtc: true,
          ).toLocal()
        : now;
    final sunset = sunsetUnix != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (sunsetUnix * 1000).toInt(),
            isUtc: true,
          ).toLocal()
        : now;

    double? rainVolume;
    if (rain != null) {
      if (rain.containsKey('1h') && rain['1h'] != null) {
        rainVolume = (rain['1h'] as num).toDouble();
      } else if (rain.containsKey('3h') && rain['3h'] != null) {
        rainVolume = (rain['3h'] as num).toDouble();
      }
    }

    final temp = ((main['temp'] as num?) ?? 0).toDouble();

    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: temp,
      feelsLike: ((main['feels_like'] as num?) ?? 0).toDouble(),
      description: firstWeather['description'] ?? '',
      iconCode: firstWeather['icon'] ?? '',
      humidity: ((main['humidity'] as num?) ?? 0).toInt(),
      windSpeed: ((wind['speed'] as num?) ?? 0).toDouble(),
      fetchedAt: now,
      windDegree: ((wind['deg'] as num?) ?? 0).toInt(),
      cloudiness: ((clouds['all'] as num?) ?? 0).toInt(),
      pressure: ((main['pressure'] as num?) ?? 1013).toInt(),
      visibility: ((json['visibility'] as num?) ?? 10000).toInt(),
      sunrise: sunrise,
      sunset: sunset,
      rainVolume: rainVolume,
      tempMin: ((main['temp_min'] as num?) ?? temp).toDouble(),
      tempMax: ((main['temp_max'] as num?) ?? temp).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': cityName,
    'main': {
      'temp': temperature,
      'feels_like': feelsLike,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'pressure': pressure,
      'humidity': humidity,
    },
    'weather': [
      {'description': description, 'icon': iconCode},
    ],
    'wind': {'speed': windSpeed, 'deg': windDegree},
    'clouds': {'all': cloudiness},
    'visibility': visibility,
    'sys': {
      'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
      'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
    },
    if (rainVolume != null) 'rain': {'1h': rainVolume},
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  /// Reconstruit un WeatherModel depuis le cache local (Hive)
  factory WeatherModel.fromCacheJson(Map<String, dynamic> json) {
    final main = (json['main'] as Map<String, dynamic>?) ?? {};
    final weatherList = (json['weather'] as List<dynamic>?) ?? [];
    final firstWeather = weatherList.isNotEmpty
        ? weatherList[0] as Map<String, dynamic>
        : <String, dynamic>{};
    final wind = (json['wind'] as Map<String, dynamic>?) ?? {};
    final clouds = (json['clouds'] as Map<String, dynamic>?) ?? {};
    final sys = (json['sys'] as Map<String, dynamic>?) ?? {};
    final rain = json['rain'] as Map<String, dynamic>?;

    final now = DateTime.now();
    final sunriseUnix = sys['sunrise'] as num?;
    final sunsetUnix = sys['sunset'] as num?;
    final sunrise = sunriseUnix != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (sunriseUnix * 1000).toInt(),
            isUtc: true,
          ).toLocal()
        : now;
    final sunset = sunsetUnix != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (sunsetUnix * 1000).toInt(),
            isUtc: true,
          ).toLocal()
        : now;

    double? rainVolume;
    if (rain != null && rain['1h'] != null) {
      rainVolume = (rain['1h'] as num).toDouble();
    }

    final temp = ((main['temp'] as num?) ?? 0).toDouble();

    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: temp,
      feelsLike: ((main['feels_like'] as num?) ?? 0).toDouble(),
      description: firstWeather['description'] ?? '',
      iconCode: firstWeather['icon'] ?? '',
      humidity: ((main['humidity'] as num?) ?? 0).toInt(),
      windSpeed: ((wind['speed'] as num?) ?? 0).toDouble(),
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'])
          : now,
      windDegree: ((wind['deg'] as num?) ?? 0).toInt(),
      cloudiness: ((clouds['all'] as num?) ?? 0).toInt(),
      pressure: ((main['pressure'] as num?) ?? 1013).toInt(),
      visibility: ((json['visibility'] as num?) ?? 10000).toInt(),
      sunrise: sunrise,
      sunset: sunset,
      rainVolume: rainVolume,
      tempMin: ((main['temp_min'] as num?) ?? temp).toDouble(),
      tempMax: ((main['temp_max'] as num?) ?? temp).toDouble(),
    );
  }
}
