import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

/// Feature bonus : cache local des prévisions (Membre C)
abstract class WeatherLocalDataSource {
  Future<void> cacheWeather(String cityKey, WeatherModel weather);
  Future<WeatherModel?> getCachedWeather(String cityKey);
  Future<void> cacheForecast(String cityKey, List<ForecastModel> forecast);
  Future<List<ForecastModel>?> getCachedForecast(String cityKey);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final Box<String> weatherBox;
  WeatherLocalDataSourceImpl(this.weatherBox);

  String _forecastKey(String cityKey) =>
      'forecast_${cityKey.toLowerCase().trim()}';

  @override
  Future<void> cacheWeather(String cityKey, WeatherModel weather) async {
    await weatherBox.put(cityKey, json.encode(weather.toJson()));
  }

  @override
  Future<WeatherModel?> getCachedWeather(String cityKey) async {
    final raw = weatherBox.get(cityKey);
    if (raw == null) return null;

    final decoded = json.decode(raw) as Map<String, dynamic>;
    final model = WeatherModel.fromCacheJson(decoded);

    // Vérifie la fraîcheur du cache (ex: 30 min) avant de le retourner
    final isExpired =
        DateTime.now().difference(model.fetchedAt) >
        CacheConstants.cacheValidity;
    return isExpired ? null : model;
  }

  @override
  Future<void> cacheForecast(
    String cityKey,
    List<ForecastModel> forecast,
  ) async {
    final listJson = forecast.map((f) => f.toJson()).toList();
    await weatherBox.put(_forecastKey(cityKey), json.encode(listJson));
  }

  @override
  Future<List<ForecastModel>?> getCachedForecast(String cityKey) async {
    final raw = weatherBox.get(_forecastKey(cityKey));
    if (raw == null) return null;

    final decoded = json.decode(raw) as List<dynamic>;
    final list = decoded
        .map(
          (item) => ForecastModel.fromCacheJson(item as Map<String, dynamic>),
        )
        .toList();

    if (list.isEmpty) return null;

    final fetchedAt = list.first.fetchedAt;
    if (fetchedAt == null) return null;

    // Vérifie la fraîcheur du cache (ex: 30 min) avant de le retourner
    final isExpired =
        DateTime.now().difference(fetchedAt) > CacheConstants.cacheValidity;
    return isExpired ? null : list;
  }
}
