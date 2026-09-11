import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/forecast_day.dart';
import '../repositories/weather_repository.dart';

/// Use case F02 — Récupère les prévisions 5 jours pour une ville
class GetForecastByCity {
  final WeatherRepository repository;
  GetForecastByCity(this.repository);

  Future<Either<Failure, List<ForecastDay>>> call(String city) {
    return repository.getForecastByCity(city);
  }
}
