import 'package:equatable/equatable.dart';

/// Entité du domaine représentant une tranche horaire de prévision (3 heures).
class ForecastHour extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final double feelsLike;
  final String description;
  final String iconCode;
  final double pop; // 0.0 to 1.0 probability of precipitation
  final double? rainVolume;
  final double windSpeed;
  final int humidity;

  const ForecastHour({
    required this.dateTime,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    this.pop = 0.0,
    this.rainVolume,
    this.windSpeed = 0.0,
    this.humidity = 0,
  });

  @override
  List<Object?> get props => [
    dateTime,
    temperature,
    feelsLike,
    description,
    iconCode,
    pop,
    rainVolume,
    windSpeed,
    humidity,
  ];
}
