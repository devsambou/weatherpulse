import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/forecast_day.dart';
import '../entities/weather.dart';

/// Contrat abstrait : la couche domain ne connaît jamais l'implémentation concrète
abstract class WeatherRepository {
  Future<Either<Failure, Weather>> getWeatherByCity(String city);
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
    double lat,
    double lon,
  );

  /// F02 — Prévisions journalières sur 5 jours
  Future<Either<Failure, List<ForecastDay>>> getForecastByCity(String city);
}
