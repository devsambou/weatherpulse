import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

/// Use case dédié au flux GPS (Membre C)
class GetWeatherByLocation {
  final WeatherRepository repository;
  GetWeatherByLocation(this.repository);

  Future<Either<Failure, Weather>> call(double lat, double lon) {
    return repository.getWeatherByCoordinates(lat, lon);
  }
}
