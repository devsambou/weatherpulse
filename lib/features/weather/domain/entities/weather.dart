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

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.fetchedAt,
  });

  @override
  List<Object> get props => [
    cityName,
    temperature,
    feelsLike,
    description,
    iconCode,
    humidity,
    windSpeed,
    fetchedAt,
  ];
}
