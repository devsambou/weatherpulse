import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/weather_model.dart';

/// Feature bonus : cache local des prévisions (Membre C)
abstract class WeatherLocalDataSource {
  Future<void> cacheWeather(String cityKey, WeatherModel weather);
  Future<WeatherModel?> getCachedWeather(String cityKey);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final Box<String> weatherBox;
  WeatherLocalDataSourceImpl(this.weatherBox);

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
    final isExpired = DateTime.now().difference(model.fetchedAt) > CacheConstants.cacheValidity;
    return isExpired ? null : model;
  }
}
