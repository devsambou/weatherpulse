import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/forecast_hour_model.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

/// Feature bonus : cache local des prévisions (Membre C)
abstract class WeatherLocalDataSource {
  Future<void> cacheWeather(String cityKey, WeatherModel weather);
  Future<WeatherModel?> getCachedWeather(String cityKey);
  Future<void> cacheForecast(String cityKey, List<ForecastModel> forecast);
  Future<List<ForecastModel>?> getCachedForecast(String cityKey);
  Future<void> cacheHourlyForecast(
    String cityKey,
    List<ForecastHourModel> forecast,
  );
  Future<List<ForecastHourModel>?> getCachedHourlyForecast(String cityKey);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final Box<String> weatherBox;
  WeatherLocalDataSourceImpl(this.weatherBox);

  String _forecastKey(String cityKey) =>
      'forecast_${cityKey.toLowerCase().trim()}';

  String _hourlyForecastKey(String cityKey) =>
      'hourly_${cityKey.toLowerCase().trim()}';

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

  @override
  Future<void> cacheHourlyForecast(
    String cityKey,
    List<ForecastHourModel> forecast,
  ) async {
    final payload = {
      'cachedAt': DateTime.now().toIso8601String(),
      'items': forecast.map((f) => f.toJson()).toList(),
    };
    await weatherBox.put(_hourlyForecastKey(cityKey), json.encode(payload));
  }

  @override
  Future<List<ForecastHourModel>?> getCachedHourlyForecast(
    String cityKey,
  ) async {
    final raw = weatherBox.get(_hourlyForecastKey(cityKey));
    if (raw == null) return null;

    final decoded = json.decode(raw) as Map<String, dynamic>;
    final cachedAtStr = decoded['cachedAt'] as String?;
    if (cachedAtStr != null) {
      final cachedAt = DateTime.parse(cachedAtStr);
      if (DateTime.now().difference(cachedAt) > CacheConstants.cacheValidity) {
        return null;
      }
    }

    final items = decoded['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) return null;

    return items
        .map(
          (item) =>
              ForecastHourModel.fromCacheJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
