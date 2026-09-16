import '../../domain/entities/forecast_hour.dart';

/// Model d'une tranche horaire de 3h (issu de l'endpoint /forecast).
class ForecastHourModel extends ForecastHour {
  const ForecastHourModel({
    required super.dateTime,
    required super.temperature,
    required super.feelsLike,
    required super.description,
    required super.iconCode,
    super.pop,
    super.rainVolume,
    super.windSpeed,
    super.humidity,
  });

  factory ForecastHourModel.fromJson(Map<String, dynamic> json) {
    final main = (json['main'] as Map<String, dynamic>?) ?? {};
    final weatherList = (json['weather'] as List<dynamic>?) ?? [];
    final firstWeather = weatherList.isNotEmpty
        ? weatherList[0] as Map<String, dynamic>
        : <String, dynamic>{};
    final wind = (json['wind'] as Map<String, dynamic>?) ?? {};
    final rain = json['rain'] as Map<String, dynamic>?;

    DateTime dateTime;
    if (json['dt_txt'] != null) {
      // dt_txt est en UTC dans l'API OpenWeather
      dateTime =
          DateTime.tryParse('${json['dt_txt']}Z')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(
            ((json['dt'] as num?)?.toInt() ?? 0) * 1000,
            isUtc: true,
          ).toLocal();
    } else if (json['dt'] != null) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as num).toInt()) * 1000,
        isUtc: true,
      ).toLocal();
    } else {
      dateTime = DateTime.now();
    }

    double? rainVolume;
    if (rain != null) {
      if (rain.containsKey('3h') && rain['3h'] != null) {
        rainVolume = (rain['3h'] as num).toDouble();
      } else if (rain.containsKey('1h') && rain['1h'] != null) {
        rainVolume = (rain['1h'] as num).toDouble();
      }
    }

    return ForecastHourModel(
      dateTime: dateTime,
      temperature: ((main['temp'] as num?) ?? 0).toDouble(),
      feelsLike: ((main['feels_like'] as num?) ?? 0).toDouble(),
      description: firstWeather['description'] ?? '',
      iconCode: firstWeather['icon'] ?? '',
      pop: ((json['pop'] as num?) ?? 0.0).toDouble(),
      rainVolume: rainVolume,
      windSpeed: ((wind['speed'] as num?) ?? 0).toDouble(),
      humidity: ((main['humidity'] as num?) ?? 0).toInt(),
    );
  }

  static List<ForecastHourModel> fromForecastJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>? ?? [];
    return list
        .map((e) => ForecastHourModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    'temperature': temperature,
    'feelsLike': feelsLike,
    'description': description,
    'iconCode': iconCode,
    'pop': pop,
    if (rainVolume != null) 'rainVolume': rainVolume,
    'windSpeed': windSpeed,
    'humidity': humidity,
  };

  factory ForecastHourModel.fromCacheJson(Map<String, dynamic> json) {
    return ForecastHourModel(
      dateTime: DateTime.parse(json['dateTime'] as String),
      temperature: ((json['temperature'] as num?) ?? 0).toDouble(),
      feelsLike: ((json['feelsLike'] as num?) ?? 0).toDouble(),
      description: json['description'] as String? ?? '',
      iconCode: json['iconCode'] as String? ?? '',
      pop: ((json['pop'] as num?) ?? 0.0).toDouble(),
      rainVolume: (json['rainVolume'] as num?)?.toDouble(),
      windSpeed: ((json['windSpeed'] as num?) ?? 0).toDouble(),
      humidity: ((json['humidity'] as num?) ?? 0).toInt(),
    );
  }
}
