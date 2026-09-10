import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/weather.dart';
import 'weather_providers.dart';

/// ViewModel de l'écran principal (F05).
///
/// Expose l'état de la météo courante sous forme d'`AsyncValue<Weather?>` :
///  - `AsyncLoading`               -> chargement en cours ;
///  - `AsyncError(Failure, _)`     -> erreur affichable via `Failure.message` (F03) ;
///  - `AsyncData(null)`            -> état initial, aucune ville chargée ;
///  - `AsyncData(Weather)`         -> données prêtes.
///
/// La présentation ne parle qu'aux use cases : aucune dépendance directe à la
/// couche `data` ni au réseau.
final weatherViewModelProvider =
    AsyncNotifierProvider<WeatherViewModel, Weather?>(WeatherViewModel.new);

class WeatherViewModel extends AsyncNotifier<Weather?> {
  String? _lastCity;
  ({double lat, double lon})? _lastCoords;

  @override
  Future<Weather?> build() async => null;

  /// Charge la météo d'une ville saisie (F01 depuis l'UI, affichage F05).
  Future<void> loadByCity(String city) async {
    final query = city.trim();
    if (query.isEmpty) return;

    state = const AsyncValue.loading();
    final result = await ref.read(getWeatherByCityProvider).call(query);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (weather) {
        _lastCity = query;
        _lastCoords = null;
        return AsyncValue.data(weather);
      },
    );
  }

  /// Charge la météo pour des coordonnées GPS (fournies par la Géolocalisation).
  Future<void> loadByCoordinates(double latitude, double longitude) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(getWeatherByLocationProvider)
        .call(latitude, longitude);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (weather) {
        _lastCoords = (lat: latitude, lon: longitude);
        _lastCity = null;
        return AsyncValue.data(weather);
      },
    );
  }

  /// Récupère la position de l'appareil puis la météo correspondante (F04).
  ///
  /// Nécessite que [locationServiceProvider] soit implémenté par la
  /// Géolocalisation ; sinon l'UI affiche l'erreur correspondante.
  Future<void> loadFromDeviceLocation() async {
    state = const AsyncValue.loading();
    try {
      final position = await ref
          .read(locationServiceProvider)
          .currentPosition();
      await loadByCoordinates(position.latitude, position.longitude);
    } on Failure catch (failure) {
      state = AsyncValue.error(failure, StackTrace.current);
    } catch (error) {
      state = AsyncValue.error(
        const LocationFailure('Impossible de récupérer votre position.'),
        StackTrace.current,
      );
    }
  }

  /// Relance la dernière requête (pull-to-refresh / bouton « Réessayer »).
  Future<void> refresh() {
    final coords = _lastCoords;
    if (coords != null) return loadByCoordinates(coords.lat, coords.lon);
    final city = _lastCity;
    if (city != null) return loadByCity(city);
    return Future<void>.value();
  }
}
