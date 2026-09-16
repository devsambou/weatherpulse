import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/forecast_hour.dart';
import '../repositories/weather_repository.dart';

/// Use case F06 — Récupère les prévisions horaires (tranches de 3h) pour une ville
class GetForecastHoursByCity {
  final WeatherRepository repository;
  GetForecastHoursByCity(this.repository);

  Future<Either<Failure, List<ForecastHour>>> call(String city) {
    return repository.getForecastHoursByCity(city);
  }
}
