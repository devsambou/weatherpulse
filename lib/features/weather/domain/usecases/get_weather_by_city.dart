import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

/// Use case = une seule responsabilité métier, appelée depuis la presentation
class GetWeatherByCity {
  final WeatherRepository repository;
  GetWeatherByCity(this.repository);

  Future<Either<Failure, Weather>> call(String city) {
    return repository.getWeatherByCity(city);
  }
}
