import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeatherByCity(String city);
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final http.Client client;
  WeatherRemoteDataSourceImpl(this.client);

  @override
  Future<WeatherModel> getWeatherByCity(String city) async {
    final response = await client.get(Uri.parse(ApiConstants.currentWeatherByCity(city)));
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    }
    throw Exception('Erreur API OpenWeather : ${response.statusCode}');
  }

  @override
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    final response =
        await client.get(Uri.parse(ApiConstants.currentWeatherByCoords(lat, lon)));
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    }
    throw Exception('Erreur API OpenWeather : ${response.statusCode}');
  }
}
