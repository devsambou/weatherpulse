import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weatherpulse_g16/core/errors/exceptions.dart';
import 'package:weatherpulse_g16/features/weather/data/datasources/weather_remote_datasource.dart';
import '../../helpers/test_environment.dart';

void main() {
  setUpAll(setupTestEnvironment);

  const tWeatherJson = {
    'name': 'Dakar',
    'main': {'temp': 29.5, 'feels_like': 31.0, 'humidity': 70},
    'weather': [
      {'description': 'ciel dégagé', 'icon': '01d'},
    ],
    'wind': {'speed': 3.2},
  };

  const tForecastJson = {
    'cod': '200',
    'cnt': 1,
    'list': [
      {
        'dt': 1705312800,
        'dt_txt': '2024-01-15 06:00:00',
        'main': {
          'temp': 10.0,
          'temp_min': 8.0,
          'temp_max': 12.0,
          'humidity': 75,
        },
        'weather': [
          {'description': 'nuageux', 'icon': '04d'},
        ],
      },
    ],
  };

  group('WeatherRemoteDataSourceImpl', () {
    test('getWeatherByCity 200 retourne WeatherModel', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode(tWeatherJson), 200);
      });
      final dataSource = WeatherRemoteDataSourceImpl(client);

      final result = await dataSource.getWeatherByCity('Dakar');
      expect(result.cityName, 'Dakar');
      expect(result.temperature, 29.5);
    });

    test('getWeatherByCoordinates 200 retourne WeatherModel', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode(tWeatherJson), 200);
      });
      final dataSource = WeatherRemoteDataSourceImpl(client);

      final result = await dataSource.getWeatherByCoordinates(14.69, -17.44);
      expect(result.cityName, 'Dakar');
    });

    test('getForecastByCity 200 retourne List<ForecastModel>', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode(tForecastJson), 200);
      });
      final dataSource = WeatherRemoteDataSourceImpl(client);

      final result = await dataSource.getForecastByCity('Dakar');
      expect(result.length, 1);
      expect(result.first.tempMin, 8.0);
    });

    test(
      'getForecastHoursByCity 200 retourne List<ForecastHourModel>',
      () async {
        final client = MockClient((request) async {
          return http.Response(json.encode(tForecastJson), 200);
        });
        final dataSource = WeatherRemoteDataSourceImpl(client);

        final result = await dataSource.getForecastHoursByCity('Dakar');
        expect(result.length, 1);
        expect(result.first.temperature, 10.0);
      },
    );

    test('404 lève CityNotFoundException', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });
      final dataSource = WeatherRemoteDataSourceImpl(client);

      expect(
        () => dataSource.getWeatherByCity('UnknownCity'),
        throwsA(isA<CityNotFoundException>()),
      );
    });

    test('429 lève QuotaExceededException', () async {
      final client = MockClient((request) async {
        return http.Response('Too Many Requests', 429);
      });
      final dataSource = WeatherRemoteDataSourceImpl(client);

      expect(
        () => dataSource.getWeatherByCity('Dakar'),
        throwsA(isA<QuotaExceededException>()),
      );
    });

    test('500 lève ServerException', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });
      final dataSource = WeatherRemoteDataSourceImpl(client);

      expect(
        () => dataSource.getWeatherByCity('Dakar'),
        throwsA(isA<ServerException>()),
      );
    });

    test('Autre code d\'erreur HTTP (ex: 418) lève ServerException', () async {
      final client = MockClient((request) async {
        return http.Response("I'm a teapot", 418);
      });
      final dataSource = WeatherRemoteDataSourceImpl(client);

      expect(
        () => dataSource.getWeatherByCity('Dakar'),
        throwsA(isA<ServerException>()),
      );
    });

    test('SocketException lève NetworkException', () async {
      final client = MockClient((request) async {
        throw const SocketException('No Internet');
      });
      final dataSource = WeatherRemoteDataSourceImpl(client);

      expect(
        () => dataSource.getWeatherByCity('Dakar'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('JSON invalide lève ServerException', () async {
      final client = MockClient((request) async {
        return http.Response('invalid json {', 200);
      });
      final dataSource = WeatherRemoteDataSourceImpl(client);

      expect(
        () => dataSource.getWeatherByCity('Dakar'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
