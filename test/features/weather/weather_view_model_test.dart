import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/get_weather_by_city.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/get_weather_by_location.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_providers.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_view_model.dart';

class FakeGetWeatherByCity extends Fake implements GetWeatherByCity {
  Either<Failure, Weather>? result;
  String? lastCity;
  int callCount = 0;

  @override
  Future<Either<Failure, Weather>> call(String city) async {
    callCount++;
    lastCity = city;
    return result!;
  }
}

class FakeGetWeatherByLocation extends Fake implements GetWeatherByLocation {
  Either<Failure, Weather>? result;
  double? lastLat;
  double? lastLon;
  int callCount = 0;

  @override
  Future<Either<Failure, Weather>> call(double lat, double lon) async {
    callCount++;
    lastLat = lat;
    lastLon = lon;
    return result!;
  }
}

class FakeLocationService implements LocationService {
  ({double latitude, double longitude})? positionToReturn;
  Object? errorToThrow;
  int callCount = 0;

  @override
  Future<({double latitude, double longitude})> currentPosition() async {
    callCount++;
    if (errorToThrow != null) throw errorToThrow!;
    return positionToReturn!;
  }
}

void main() {
  late FakeGetWeatherByCity fakeGetWeatherByCity;
  late FakeGetWeatherByLocation fakeGetWeatherByLocation;
  late FakeLocationService fakeLocationService;
  late ProviderContainer container;

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

  setUp(() {
    fakeGetWeatherByCity = FakeGetWeatherByCity();
    fakeGetWeatherByLocation = FakeGetWeatherByLocation();
    fakeLocationService = FakeLocationService();

    container = ProviderContainer(
      overrides: [
        getWeatherByCityProvider.overrideWithValue(fakeGetWeatherByCity),
        getWeatherByLocationProvider.overrideWithValue(
          fakeGetWeatherByLocation,
        ),
        locationServiceProvider.overrideWithValue(fakeLocationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WeatherViewModel', () {
    test('l\'état initial est AsyncData(null)', () async {
      final state = await container.read(weatherViewModelProvider.future);
      expect(state, isNull);
    });

    test('loadByCity avec chaîne vide ne fait rien', () async {
      await container.read(weatherViewModelProvider.notifier).loadByCity('   ');
      final state = container.read(weatherViewModelProvider);
      expect(state.value, isNull);
      expect(fakeGetWeatherByCity.callCount, 0);
    });

    test('loadByCity avec succès met à jour l\'état avec la météo', () async {
      fakeGetWeatherByCity.result = Right(tWeather);

      await container
          .read(weatherViewModelProvider.notifier)
          .loadByCity('Dakar');

      final state = container.read(weatherViewModelProvider);
      expect(state.value, equals(tWeather));
      expect(fakeGetWeatherByCity.callCount, 1);
    });

    test('loadByCity avec échec met l\'état en AsyncError', () async {
      const failure = CityNotFoundFailure('Ville introuvable');
      fakeGetWeatherByCity.result = const Left(failure);

      await container
          .read(weatherViewModelProvider.notifier)
          .loadByCity('Inconnue');

      final state = container.read(weatherViewModelProvider);
      expect(state.hasError, isTrue);
      expect(state.error, equals(failure));
    });

    test('loadByCoordinates avec succès met à jour l\'état', () async {
      fakeGetWeatherByLocation.result = Right(tWeather);

      await container
          .read(weatherViewModelProvider.notifier)
          .loadByCoordinates(14.69, -17.44);

      final state = container.read(weatherViewModelProvider);
      expect(state.value, equals(tWeather));
      expect(fakeGetWeatherByLocation.callCount, 1);
    });

    test('loadByCoordinates avec échec met l\'état en erreur', () async {
      const failure = NetworkFailure('Pas de réseau');
      fakeGetWeatherByLocation.result = const Left(failure);

      await container
          .read(weatherViewModelProvider.notifier)
          .loadByCoordinates(14.69, -17.44);

      final state = container.read(weatherViewModelProvider);
      expect(state.hasError, isTrue);
    });

    test('loadFromDeviceLocation avec succès charge les coordonnées', () async {
      fakeLocationService.positionToReturn = (
        latitude: 14.69,
        longitude: -17.44,
      );
      fakeGetWeatherByLocation.result = Right(tWeather);

      await container
          .read(weatherViewModelProvider.notifier)
          .loadFromDeviceLocation();

      final state = container.read(weatherViewModelProvider);
      expect(state.value, equals(tWeather));
      expect(fakeLocationService.callCount, 1);
      expect(fakeGetWeatherByLocation.callCount, 1);
    });

    test('loadFromDeviceLocation avec Failure capture l\'erreur', () async {
      fakeLocationService.errorToThrow = const LocationFailure(
        'Permission refusée',
      );

      await container
          .read(weatherViewModelProvider.notifier)
          .loadFromDeviceLocation();

      final state = container.read(weatherViewModelProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<LocationFailure>());
    });

    test(
      'loadFromDeviceLocation avec Exception générique capture LocationFailure',
      () async {
        fakeLocationService.errorToThrow = Exception('Erreur inconnue');

        await container
            .read(weatherViewModelProvider.notifier)
            .loadFromDeviceLocation();

        final state = container.read(weatherViewModelProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<LocationFailure>());
      },
    );

    test('refresh recharge la dernière ville ou coordonnées', () async {
      // 1. Refresh quand rien n'est chargé
      await container.read(weatherViewModelProvider.notifier).refresh();

      // 2. Refresh quand une ville a été chargée
      fakeGetWeatherByCity.result = Right(tWeather);
      await container
          .read(weatherViewModelProvider.notifier)
          .loadByCity('Dakar');
      await container.read(weatherViewModelProvider.notifier).refresh();
      expect(fakeGetWeatherByCity.callCount, 2);

      // 3. Refresh quand des coordonnées ont été chargées
      fakeGetWeatherByLocation.result = Right(tWeather);
      await container
          .read(weatherViewModelProvider.notifier)
          .loadByCoordinates(10.0, 20.0);
      await container.read(weatherViewModelProvider.notifier).refresh();
      expect(fakeGetWeatherByLocation.callCount, 2);
    });
  });
}
