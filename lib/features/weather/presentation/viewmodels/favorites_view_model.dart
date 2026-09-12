import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/favorite_city.dart';
import 'favorites_providers.dart';
import 'weather_providers.dart';

/// ViewModel pour la gestion des villes favorites (F07).
///
/// Expose la liste des villes favorites sous forme d'`AsyncValue<List<FavoriteCity>>`.
final favoritesViewModelProvider =
    AsyncNotifierProvider<FavoritesViewModel, List<FavoriteCity>>(
      FavoritesViewModel.new,
    );

class FavoritesViewModel extends AsyncNotifier<List<FavoriteCity>> {
  @override
  Future<List<FavoriteCity>> build() async {
    final result = await ref.read(getFavoritesProvider).call();
    return result.fold((failure) => throw failure, (list) => list);
  }

  /// Vérifie si une ville est favorite parmi la liste courante (insensible à la casse).
  bool isCityFavorite(String cityName) {
    final list = state.value ?? [];
    final normalized = cityName.trim().toLowerCase();
    return list.any((city) => city.cityName.toLowerCase() == normalized);
  }

  /// Ajoute ou retire une ville des favoris.
  Future<void> toggleFavorite(String cityName) async {
    final cleanCity = cityName.trim();
    if (cleanCity.isEmpty) return;

    if (isCityFavorite(cleanCity)) {
      await removeCity(cleanCity);
    } else {
      await addCity(cleanCity);
    }
  }

  /// Ajoute une ville aux favoris en validant son existence via [GetWeatherByCity].
  Future<void> addCity(String cityName) async {
    final cleanCity = cityName.trim();
    if (cleanCity.isEmpty) return;

    // F07 : Valider qu'une ville existe réellement avant de l'ajouter en favori
    final weatherCheck = await ref
        .read(getWeatherByCityProvider)
        .call(cleanCity);

    final resolvedCity = weatherCheck.fold((failure) {
      state = AsyncValue.error(failure, StackTrace.current);
      return null;
    }, (weather) => weather.cityName);

    if (resolvedCity == null) return;

    final city = FavoriteCity(cityName: resolvedCity, addedAt: DateTime.now());

    final addResult = await ref.read(addFavoriteProvider).call(city);

    addResult.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) {
        ref.invalidateSelf();
      },
    );
  }

  /// Retire une ville des favoris.
  Future<void> removeCity(String cityName) async {
    final cleanCity = cityName.trim();
    if (cleanCity.isEmpty) return;

    final removeResult = await ref.read(removeFavoriteProvider).call(cleanCity);

    removeResult.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) {
        ref.invalidateSelf();
      },
    );
  }
}
