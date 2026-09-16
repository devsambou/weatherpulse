import 'package:equatable/equatable.dart';

/// Entité pure du domaine : aucune dépendance à l'API, au JSON ou au cache
class Weather extends Equatable {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final DateTime fetchedAt;
  final int windDegree;
  final int cloudiness;
  final int pressure;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;
  final double? rainVolume;
  final double tempMin;
  final double tempMax;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.fetchedAt,
    this.windDegree = 0,
    this.cloudiness = 0,
    this.pressure = 1013,
    this.visibility = 10000,
    required this.sunrise,
    required this.sunset,
    this.rainVolume,
    this.tempMin = 0.0,
    this.tempMax = 0.0,
  });

  @override
  List<Object?> get props => [
    cityName,
    temperature,
    feelsLike,
    description,
    iconCode,
    humidity,
    windSpeed,
    fetchedAt,
    windDegree,
    cloudiness,
    pressure,
    visibility,
    sunrise,
    sunset,
    rainVolume,
    tempMin,
    tempMax,
  ];
}
