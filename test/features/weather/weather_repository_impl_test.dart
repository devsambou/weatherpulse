import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/exceptions.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/data/datasources/weather_local_datasource.dart';
import 'package:weatherpulse_g16/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:weatherpulse_g16/features/weather/data/models/forecast_hour_model.dart';
import 'package:weatherpulse_g16/features/weather/data/models/forecast_model.dart';
import 'package:weatherpulse_g16/features/weather/data/models/weather_model.dart';
import 'package:weatherpulse_g16/features/weather/data/repositories/weather_repository_impl.dart';

// ---------------------------------------------------------------------------
// Mocks écrits manuellement (pas de build_runner requis)
// ---------------------------------------------------------------------------

class MockWeatherRemoteDataSource implements WeatherRemoteDataSource {
  WeatherModel? weatherResult;
  List<ForecastModel>? forecastResult;
  List<ForecastHourModel>? hourlyForecastResult;
  Exception? errorToThrow;

  @override
  Future<WeatherModel> getWeatherByCity(String city) async {
    if (errorToThrow != null) throw errorToThrow!;
    return weatherResult!;
  }

  @override
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    if (errorToThrow != null) throw errorToThrow!;
    return weatherResult!;
  }

  @override
  Future<List<ForecastModel>> getForecastByCity(String city) async {
    if (errorToThrow != null) throw errorToThrow!;
    return forecastResult!;
  }

  @override
  Future<List<ForecastHourModel>> getForecastHoursByCity(String city) async {
    if (errorToThrow != null) throw errorToThrow!;
    return hourlyForecastResult ?? [];
  }
}

class MockWeatherLocalDataSource implements WeatherLocalDataSource {
  WeatherModel? cachedResult;
  List<ForecastModel>? cachedForecastResult;
  List<ForecastHourModel>? cachedHourlyResult;
  bool cacheWasCalled = false;
  bool cacheForecastWasCalled = false;
  bool cacheHourlyWasCalled = false;

  @override
  Future<WeatherModel?> getCachedWeather(String cityKey) async => cachedResult;

  @override
  Future<void> cacheWeather(String cityKey, WeatherModel weather) async {
    cacheWasCalled = true;
  }

  @override
  Future<List<ForecastModel>?> getCachedForecast(String cityKey) async =>
      cachedForecastResult;

  @override
  Future<void> cacheForecast(
    String cityKey,
    List<ForecastModel> forecast,
  ) async {
    cacheForecastWasCalled = true;
  }

  @override
  Future<List<ForecastHourModel>?> getCachedHourlyForecast(
    String cityKey,
  ) async => cachedHourlyResult;

  @override
  Future<void> cacheHourlyForecast(
    String cityKey,
    List<ForecastHourModel> forecast,
  ) async {
    cacheHourlyWasCalled = true;
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final tWeatherModel = WeatherModel(
  cityName: 'Paris',
  temperature: 18.5,
  feelsLike: 17.0,
  description: 'partiellement nuageux',
  iconCode: '03d',
  humidity: 65,
  windSpeed: 4.2,
  fetchedAt: DateTime(2024, 1, 15, 12),
  sunrise: DateTime(2024, 1, 15, 7, 30),
  sunset: DateTime(2024, 1, 15, 18, 0),
);

final tForecastModel = ForecastModel(
  date: DateTime(2024, 1, 15),
  tempMin: 8.0,
  tempMax: 17.0,
  description: 'ciel dégagé',
  iconCode: '01d',
  fetchedAt: DateTime(2024, 1, 15, 12),
);

final tForecastList = [tForecastModel];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late WeatherRepositoryImpl repository;
  late MockWeatherRemoteDataSource mockRemote;
  late MockWeatherLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockWeatherRemoteDataSource();
    mockLocal = MockWeatherLocalDataSource();
    repository = WeatherRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  // ─── F01 : Météo actuelle ────────────────────────────────────────────────

  group('getWeatherByCity — F01', () {
    test(
      'retourne Right(Weather) quand le cache est vide et le réseau répond (sauvegarde en cache)',
      () async {
        mockLocal.cachedResult = null;
        mockRemote.weatherResult = tWeatherModel;

        final result = await repository.getWeatherByCity('Paris');

        expect(result, Right(tWeatherModel));
        expect(mockLocal.cacheWasCalled, isTrue);
      },
    );

    test(
      'retourne Right(Weather) depuis le cache sans appel réseau (cache valide)',
      () async {
        mockLocal.cachedResult = tWeatherModel;
        // si le réseau est appelé, il lance une erreur — ce qui échouerait le test
        mockRemote.errorToThrow = const NetworkException();

        final result = await repository.getWeatherByCity('Paris');

        expect(result, Right(tWeatherModel));
      },
    );

    test(
      'ré-appelle l\'API et sauvegarde le résultat quand le cache est expiré (null)',
      () async {
        mockLocal.cachedResult = null;
        mockRemote.weatherResult = tWeatherModel;

        final result = await repository.getWeatherByCity('Paris');

        expect(result, Right(tWeatherModel));
        expect(mockLocal.cacheWasCalled, isTrue);
      },
    );
  });

  // ─── F03 : Gestion des erreurs ───────────────────────────────────────────

  group('getWeatherByCity — F03 : erreurs API', () {
    setUp(() => mockLocal.cachedResult = null);

    test(
      'retourne CityNotFoundFailure quand le datasource lève CityNotFoundException (404)',
      () async {
        mockRemote.errorToThrow = const CityNotFoundException();

        final result = await repository.getWeatherByCity('VilleInexistante');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CityNotFoundFailure>()),
          (_) => fail('Devrait être un Left'),
        );
      },
    );

    test(
      'retourne QuotaExceededFailure quand le datasource lève QuotaExceededException (429)',
      () async {
        mockRemote.errorToThrow = const QuotaExceededException();

        final result = await repository.getWeatherByCity('Paris');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<QuotaExceededFailure>()),
          (_) => fail('Devrait être un Left'),
        );
      },
    );

    test(
      'retourne NetworkFailure quand le datasource lève NetworkException (pas de réseau)',
      () async {
        mockRemote.errorToThrow = const NetworkException();

        final result = await repository.getWeatherByCity('Paris');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Devrait être un Left'),
        );
      },
    );

    test(
      'retourne ServerErrorFailure quand le datasource lève ServerException (5xx)',
      () async {
        mockRemote.errorToThrow = const ServerException(
          statusCode: 503,
          message: 'Service indisponible',
        );

        final result = await repository.getWeatherByCity('Paris');

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<ServerErrorFailure>());
          expect((failure as ServerErrorFailure).statusCode, 503);
        }, (_) => fail('Devrait être un Left'));
      },
    );

    test(
      'retourne ServerFailure générique pour toute autre exception',
      () async {
        mockRemote.errorToThrow = Exception('Erreur inconnue');

        final result = await repository.getWeatherByCity('Paris');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Devrait être un Left'),
        );
      },
    );
  });

  // ─── F03 : Erreurs pour getWeatherByCoordinates ──────────────────────────

  group('getWeatherByCoordinates — F03', () {
    setUp(() => mockLocal.cachedResult = null);

    test(
      'retourne CityNotFoundFailure (404) pour des coordonnées invalides',
      () async {
        mockRemote.errorToThrow = const CityNotFoundException();

        final result = await repository.getWeatherByCoordinates(999, 999);

        result.fold(
          (failure) => expect(failure, isA<CityNotFoundFailure>()),
          (_) => fail('Devrait être un Left'),
        );
      },
    );

    test('retourne NetworkFailure en cas de timeout', () async {
      mockRemote.errorToThrow = const NetworkException(
        'La requête a expiré (timeout)',
      );

      final result = await repository.getWeatherByCoordinates(48.8, 2.3);

      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, contains('timeout'));
      }, (_) => fail('Devrait être un Left'));
    });
  });

  // ─── F02 & F09 : Prévisions et Cache (repository level) ───────────────────

  group('getForecastByCity — F02 & F09', () {
    test(
      'retourne Right(List<ForecastDay>) quand le cache est vide et le réseau répond (sauvegarde en cache)',
      () async {
        mockLocal.cachedForecastResult = null;
        mockRemote.forecastResult = tForecastList;

        final result = await repository.getForecastByCity('Paris');

        expect(result, Right(tForecastList));
        expect(mockLocal.cacheForecastWasCalled, isTrue);
      },
    );

    test(
      'retourne Right(List<ForecastDay>) depuis le cache sans appel réseau (cache valide)',
      () async {
        mockLocal.cachedForecastResult = tForecastList;
        // Si le réseau est appelé, il lance une erreur réseau
        mockRemote.errorToThrow = const NetworkException();

        final result = await repository.getForecastByCity('Paris');

        expect(result, Right(tForecastList));
      },
    );

    test(
      'ré-appelle l\'API et sauvegarde quand le cache est expiré (null)',
      () async {
        mockLocal.cachedForecastResult = null;
        mockRemote.forecastResult = tForecastList;

        final result = await repository.getForecastByCity('Paris');

        expect(result, Right(tForecastList));
        expect(mockLocal.cacheForecastWasCalled, isTrue);
      },
    );

    test(
      'retourne CityNotFoundFailure si la ville est introuvable (404)',
      () async {
        mockLocal.cachedForecastResult = null;
        mockRemote.errorToThrow = const CityNotFoundException();

        final result = await repository.getForecastByCity('VilleInexistante');

        result.fold(
          (failure) => expect(failure, isA<CityNotFoundFailure>()),
          (_) => fail('Devrait être un Left'),
        );
      },
    );
  });
}
