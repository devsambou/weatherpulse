import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_day.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_hour.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';
import 'package:weatherpulse_g16/features/weather/domain/repositories/weather_repository.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/get_weather_by_location.dart';

class FakeWeatherRepository implements WeatherRepository {
  Weather? weatherToReturn;
  Failure? failureToReturn;
  double? lastLat;
  double? lastLon;
  int callCount = 0;

  @override
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    callCount++;
    lastLat = lat;
    lastLon = lon;
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(weatherToReturn!);
  }

  @override
  Future<Either<Failure, Weather>> getWeatherByCity(String city) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<ForecastDay>>> getForecastByCity(
    String city,
  ) async => throw UnimplementedError();

  @override
  Future<Either<Failure, List<ForecastHour>>> getForecastHoursByCity(
    String city,
  ) async => throw UnimplementedError();
}

void main() {
  late FakeWeatherRepository fakeRepository;
  late GetWeatherByLocation useCase;

  setUp(() {
    fakeRepository = FakeWeatherRepository();
    useCase = GetWeatherByLocation(fakeRepository);
  });

  final tWeather = Weather(
    cityName: 'Dakar',
    temperature: 30.0,
    feelsLike: 32.0,
    description: 'ensoleillé',
    iconCode: '01d',
    humidity: 60,
    windSpeed: 4.0,
    fetchedAt: DateTime(2024, 1, 1),
    sunrise: DateTime(2024, 1, 1),
    sunset: DateTime(2024, 1, 1),
  );

  test(
    'appelle repository.getWeatherByCoordinates avec les coordonnées',
    () async {
      fakeRepository.weatherToReturn = tWeather;

      final result = await useCase.call(14.69, -17.44);

      expect(result, Right(tWeather));
      expect(fakeRepository.callCount, 1);
      expect(fakeRepository.lastLat, 14.69);
      expect(fakeRepository.lastLon, -17.44);
    },
  );
}
