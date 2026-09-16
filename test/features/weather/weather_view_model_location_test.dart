import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_day.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_hour.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';
import 'package:weatherpulse_g16/features/weather/domain/repositories/weather_repository.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_providers.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_view_model.dart';

// ---------------------------------------------------------------------------
// Mocks écrits manuellement (cohérent avec le style des autres tests du repo)
// ---------------------------------------------------------------------------

class _FakeWeatherRepository implements WeatherRepository {
  Either<Failure, Weather>? coordinatesResult;

  @override
  Future<Either<Failure, Weather>> getWeatherByCity(String city) async {
    throw UnimplementedError('Non utilisé dans ce test');
  }

  @override
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async => coordinatesResult!;

  @override
  Future<Either<Failure, List<ForecastDay>>> getForecastByCity(
    String city,
  ) async {
    throw UnimplementedError('Non utilisé dans ce test');
  }

  @override
  Future<Either<Failure, List<ForecastHour>>> getForecastHoursByCity(
    String city,
  ) async {
    throw UnimplementedError('Non utilisé dans ce test');
  }
}

class _FakeLocationService implements LocationService {
  ({double latitude, double longitude})? position;
  Object? errorToThrow;

  @override
  Future<({double latitude, double longitude})> currentPosition() async {
    if (errorToThrow != null) throw errorToThrow!;
    return position!;
  }
}

Weather _sampleWeather() => Weather(
  cityName: 'Cotonou',
  temperature: 29.0,
  feelsLike: 31.0,
  description: 'Ciel dégagé',
  iconCode: '01d',
  humidity: 70,
  windSpeed: 3.2,
  fetchedAt: DateTime(2026, 9, 15),
  sunrise: DateTime(2026, 9, 15, 6),
  sunset: DateTime(2026, 9, 15, 18),
);

void main() {
  group('WeatherViewModel.loadFromDeviceLocation (F04)', () {
    late _FakeWeatherRepository repository;
    late _FakeLocationService locationService;
    late ProviderContainer container;

    setUp(() {
      repository = _FakeWeatherRepository();
      locationService = _FakeLocationService();
      container = ProviderContainer(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(repository),
          locationServiceProvider.overrideWithValue(locationService),
        ],
      );
      addTearDown(container.dispose);
    });

    test(
      'charge la météo de la position quand la permission est accordée',
      () async {
        locationService.position = (latitude: 6.36, longitude: 2.42);
        final weather = _sampleWeather();
        repository.coordinatesResult = Right(weather);

        // Attend l'état initial (build() -> null) avant d'agir sur le notifier.
        await container.read(weatherViewModelProvider.future);
        final notifier = container.read(weatherViewModelProvider.notifier);
        await notifier.loadFromDeviceLocation();

        final state = container.read(weatherViewModelProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, weather);
      },
    );

    test(
      'expose une LocationFailure quand la permission est refusée',
      () async {
        locationService.errorToThrow = const LocationFailure(
          'Autorisation de localisation refusée.',
        );

        await container.read(weatherViewModelProvider.future);
        final notifier = container.read(weatherViewModelProvider.notifier);
        await notifier.loadFromDeviceLocation();

        final state = container.read(weatherViewModelProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<LocationFailure>());
        expect(
          (state.error as LocationFailure).message,
          'Autorisation de localisation refusée.',
        );
      },
    );

    test(
      'convertit toute erreur technique inattendue en LocationFailure générique',
      () async {
        locationService.errorToThrow = Exception('capteur GPS indisponible');

        await container.read(weatherViewModelProvider.future);
        final notifier = container.read(weatherViewModelProvider.notifier);
        await notifier.loadFromDeviceLocation();

        final state = container.read(weatherViewModelProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<LocationFailure>());
      },
    );

    test('refresh() relance la dernière position GPS chargée', () async {
      locationService.position = (latitude: 6.36, longitude: 2.42);
      final weather = _sampleWeather();
      repository.coordinatesResult = Right(weather);

      await container.read(weatherViewModelProvider.future);
      final notifier = container.read(weatherViewModelProvider.notifier);
      await notifier.loadFromDeviceLocation();

      // Simule des données mises à jour lors du rafraîchissement.
      final refreshedWeather = _sampleWeather();
      repository.coordinatesResult = Right(refreshedWeather);
      await notifier.refresh();

      final state = container.read(weatherViewModelProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, refreshedWeather);
    });
  });
}
