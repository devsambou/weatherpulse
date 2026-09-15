import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_day.dart';
import 'package:weatherpulse_g16/features/weather/domain/repositories/weather_repository.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/get_forecast_by_city.dart';

import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_hour.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';

// ---------------------------------------------------------------------------
// Mock minimal du repository
// ---------------------------------------------------------------------------

class MockWeatherRepository implements WeatherRepository {
  Either<Failure, List<ForecastDay>>? forecastResult;

  @override
  Future<Either<Failure, List<ForecastDay>>> getForecastByCity(
    String city,
  ) async {
    return forecastResult!;
  }

  @override
  Future<Either<Failure, List<ForecastHour>>> getForecastHoursByCity(
    String city,
  ) async => const Right([]);

  @override
  Future<Either<Failure, Weather>> getWeatherByCity(String city) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Fixture
// ---------------------------------------------------------------------------

final tForecastDays = [
  ForecastDay(
    date: DateTime(2024, 1, 15),
    tempMin: 8.0,
    tempMax: 17.0,
    description: 'ciel dégagé',
    iconCode: '01d',
  ),
  ForecastDay(
    date: DateTime(2024, 1, 16),
    tempMin: 3.0,
    tempMax: 9.0,
    description: 'pluie modérée',
    iconCode: '10d',
  ),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late GetForecastByCity useCase;
  late MockWeatherRepository mockRepository;

  setUp(() {
    mockRepository = MockWeatherRepository();
    useCase = GetForecastByCity(mockRepository);
  });

  group('GetForecastByCity — F02 Use case', () {
    test(
      'retourne Right(List<ForecastDay>) quand le repository réussit',
      () async {
        mockRepository.forecastResult = Right(tForecastDays);

        final result = await useCase('Paris');

        expect(result, Right(tForecastDays));
      },
    );

    test(
      'retourne exactement les ForecastDays fournis par le repository',
      () async {
        mockRepository.forecastResult = Right(tForecastDays);

        final result = await useCase('Paris');

        result.fold((_) => fail('Devrait être un Right'), (days) {
          expect(days.length, 2);
          expect(days[0].date, DateTime(2024, 1, 15));
          expect(days[0].tempMin, 8.0);
          expect(days[0].tempMax, 17.0);
          expect(days[1].description, 'pluie modérée');
        });
      },
    );

    test('propage Left(CityNotFoundFailure) du repository', () async {
      mockRepository.forecastResult = const Left(
        CityNotFoundFailure('Ville introuvable'),
      );

      final result = await useCase('VilleInexistante');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CityNotFoundFailure>()),
        (_) => fail('Devrait être un Left'),
      );
    });

    test('propage Left(NetworkFailure) du repository', () async {
      mockRepository.forecastResult = const Left(
        NetworkFailure('Pas de connexion réseau'),
      );

      final result = await useCase('Paris');

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Devrait être un Left'),
      );
    });

    test('propage Left(QuotaExceededFailure) du repository', () async {
      mockRepository.forecastResult = const Left(
        QuotaExceededFailure('Quota dépassé'),
      );

      final result = await useCase('Paris');

      result.fold(
        (failure) => expect(failure, isA<QuotaExceededFailure>()),
        (_) => fail('Devrait être un Left'),
      );
    });

    test('retourne une liste vide quand le repository retourne []', () async {
      mockRepository.forecastResult = const Right([]);

      final result = await useCase('Paris');

      result.fold(
        (_) => fail('Devrait être un Right'),
        (days) => expect(days, isEmpty),
      );
    });
  });
}
