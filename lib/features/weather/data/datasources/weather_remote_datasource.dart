import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/forecast_hour_model.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeatherByCity(String city);
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon);
  Future<List<ForecastModel>> getForecastByCity(String city);
  Future<List<ForecastHourModel>> getForecastHoursByCity(String city);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final http.Client client;
  WeatherRemoteDataSourceImpl(this.client);

  /// Effectue un GET et mappe les codes HTTP vers les exceptions typées (F03).
  Future<Map<String, dynamic>> _getJson(String url) async {
    try {
      final response = await client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      switch (response.statusCode) {
        case 200:
          return json.decode(response.body) as Map<String, dynamic>;
        case 404:
          throw const CityNotFoundException();
        case 429:
          throw const QuotaExceededException();
        default:
          if (response.statusCode >= 500) {
            throw ServerException(statusCode: response.statusCode);
          }
          throw ServerException(
            statusCode: response.statusCode,
            message: 'Erreur API inattendue : ${response.statusCode}',
          );
      }
    } on SocketException {
      throw const NetworkException('Pas de connexion réseau');
    } on TimeoutException {
      throw const NetworkException('La requête a expiré (timeout)');
    } on CityNotFoundException {
      rethrow;
    } on QuotaExceededException {
      rethrow;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on FormatException {
      throw const ServerException(
        statusCode: 0,
        message: 'Réponse API illisible (JSON invalide)',
      );
    }
  }

  @override
  Future<WeatherModel> getWeatherByCity(String city) async {
    final data = await _getJson(ApiConstants.currentWeatherByCity(city));
    return WeatherModel.fromJson(data);
  }

  @override
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    final data = await _getJson(ApiConstants.currentWeatherByCoords(lat, lon));
    return WeatherModel.fromJson(data);
  }

  @override
  Future<List<ForecastModel>> getForecastByCity(String city) async {
    final data = await _getJson(ApiConstants.forecastByCity(city));
    return ForecastModel.fromForecastJson(data);
  }

  @override
  Future<List<ForecastHourModel>> getForecastHoursByCity(String city) async {
    final data = await _getJson(ApiConstants.forecastByCity(city));
    return ForecastHourModel.fromForecastJson(data);
  }
}
