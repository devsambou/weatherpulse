import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/favorite_city_model.dart';

/// Source de données locale Hive pour la gestion des villes favorites (F07).
abstract class FavoritesLocalDataSource {
  Future<void> addFavorite(FavoriteCityModel city);
  Future<void> removeFavorite(String cityName);
  Future<List<FavoriteCityModel>> getFavorites();
  Future<bool> isFavorite(String cityName);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final Box<String> favoritesBox;

  FavoritesLocalDataSourceImpl(this.favoritesBox);

  String _normalizeKey(String cityName) => cityName.trim().toLowerCase();

  @override
  Future<void> addFavorite(FavoriteCityModel city) async {
    final key = _normalizeKey(city.cityName);
    await favoritesBox.put(key, json.encode(city.toJson()));
  }

  @override
  Future<void> removeFavorite(String cityName) async {
    final key = _normalizeKey(cityName);
    await favoritesBox.delete(key);
  }

  @override
  Future<List<FavoriteCityModel>> getFavorites() async {
    final list = <FavoriteCityModel>[];
    for (final raw in favoritesBox.values) {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      list.add(FavoriteCityModel.fromJson(decoded));
    }
    // Trie par date d'ajout décroissante (plus récentes en premier)
    list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list;
  }

  @override
  Future<bool> isFavorite(String cityName) async {
    final key = _normalizeKey(cityName);
    return favoritesBox.containsKey(key);
  }
}
