import 'package:dartz/dartz.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_day.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';
import 'package:weatherpulse_g16/features/weather/domain/repositories/weather_repository.dart';

/// Double de test du [WeatherRepository], utilisé par les tests de la
/// couche présentation (viewmodel + widgets) sans dépendre du réseau.
class FakeWeatherRepository implements WeatherRepository {
  FakeWeatherRepository({this.shouldFail = false});

  final bool shouldFail;

  Weather _sample(String city) => Weather(
    cityName: city,
    temperature: 27,
    feelsLike: 29,
    description: 'ciel dégagé',
    iconCode: '01d',
    humidity: 55,
    windSpeed: 2.5,
    fetchedAt: DateTime(2026, 1, 1, 12),
  );

  @override
  Future<Either<Failure, Weather>> getWeatherByCity(String city) async {
    if (shouldFail) {
      return const Left(NetworkFailure('Pas de connexion internet.'));
    }
    return Right(_sample(city));
  }

  @override
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    if (shouldFail) {
      return const Left(LocationFailure('Position indisponible.'));
    }
    return Right(_sample('Dakar'));
  }

  @override
  Future<Either<Failure, List<ForecastDay>>> getForecastByCity(
    String city,
  ) async {
    if (shouldFail) {
      return const Left(NetworkFailure('Pas de connexion internet.'));
    }
    return Right(
      List.generate(
        5,
        (i) => ForecastDay(
          date: DateTime(2026, 1, 1 + i),
          tempMin: 20 + i.toDouble(),
          tempMax: 28 + i.toDouble(),
          description: 'ciel dégagé',
          iconCode: '01d',
        ),
      ),
    );
  }
}
