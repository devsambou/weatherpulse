import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:weatherpulse_g16/core/constants/api_constants.dart';
import 'package:weatherpulse_g16/features/weather/data/datasources/weather_local_datasource.dart';
import 'package:weatherpulse_g16/features/weather/data/models/forecast_model.dart';
import 'package:weatherpulse_g16/features/weather/data/models/weather_model.dart';

class FakeBox extends Fake implements Box<String> {
  final Map<dynamic, String> _storage = {};

  @override
  String? get(dynamic key, {String? defaultValue}) =>
      _storage[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, String value) async {
    _storage[key] = value;
  }
}

void main() {
  late FakeBox fakeBox;
  late WeatherLocalDataSourceImpl dataSource;

  setUp(() {
    fakeBox = FakeBox();
    dataSource = WeatherLocalDataSourceImpl(fakeBox);
  });

  final tWeatherModel = WeatherModel(
    cityName: 'Paris',
    temperature: 20.0,
    feelsLike: 19.0,
    description: 'ensoleillé',
    iconCode: '01d',
    humidity: 50,
    windSpeed: 3.5,
    fetchedAt: DateTime.now(),
  );

  final tForecastModel = ForecastModel(
    date: DateTime(2024, 1, 15),
    tempMin: 10.0,
    tempMax: 18.0,
    description: 'ciel dégagé',
    iconCode: '01d',
    fetchedAt: DateTime.now(),
  );

  group('WeatherLocalDataSource - Météo courante', () {
    test('retourne null quand le cache est vide', () async {
      final result = await dataSource.getCachedWeather('Paris');
      expect(result, isNull);
    });

    test(
      'retourne WeatherModel quand le cache est valide (< 30 min)',
      () async {
        await dataSource.cacheWeather('Paris', tWeatherModel);

        final result = await dataSource.getCachedWeather('Paris');

        expect(result, isNotNull);
        expect(result!.cityName, 'Paris');
        expect(result.temperature, 20.0);
      },
    );

    test('retourne null quand le cache est expiré (> 30 min)', () async {
      final expiredDate = DateTime.now().subtract(
        CacheConstants.cacheValidity + const Duration(minutes: 5),
      );
      final expiredWeather = WeatherModel(
        cityName: 'Paris',
        temperature: 20.0,
        feelsLike: 19.0,
        description: 'ensoleillé',
        iconCode: '01d',
        humidity: 50,
        windSpeed: 3.5,
        fetchedAt: expiredDate,
      );

      await dataSource.cacheWeather('Paris', expiredWeather);

      final result = await dataSource.getCachedWeather('Paris');
      expect(result, isNull);
    });
  });

  group('WeatherLocalDataSource - Prévisions (F09)', () {
    test('retourne null quand le cache des prévisions est vide', () async {
      final result = await dataSource.getCachedForecast('Paris');
      expect(result, isNull);
    });

    test(
      'retourne List<ForecastModel> quand le cache est valide (< 30 min)',
      () async {
        await dataSource.cacheForecast('Paris', [tForecastModel]);

        final result = await dataSource.getCachedForecast('Paris');

        expect(result, isNotNull);
        expect(result!.length, 1);
        expect(result.first.description, 'ciel dégagé');
        expect(result.first.fetchedAt, isNotNull);
      },
    );

    test(
      'retourne null quand le cache des prévisions est expiré (> 30 min)',
      () async {
        final expiredDate = DateTime.now().subtract(
          CacheConstants.cacheValidity + const Duration(minutes: 5),
        );
        final expiredForecast = ForecastModel(
          date: DateTime(2024, 1, 15),
          tempMin: 10.0,
          tempMax: 18.0,
          description: 'ciel dégagé',
          iconCode: '01d',
          fetchedAt: expiredDate,
        );

        await dataSource.cacheForecast('Paris', [expiredForecast]);

        final result = await dataSource.getCachedForecast('Paris');
        expect(result, isNull);
      },
    );

    test(
      'isole bien les clés météo et prévisions pour la même ville',
      () async {
        await dataSource.cacheWeather('Paris', tWeatherModel);
        await dataSource.cacheForecast('Paris', [tForecastModel]);

        final cachedWeather = await dataSource.getCachedWeather('Paris');
        final cachedForecast = await dataSource.getCachedForecast('Paris');

        expect(cachedWeather, isNotNull);
        expect(cachedForecast, isNotNull);
      },
    );
  });
}
