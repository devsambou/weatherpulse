import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_weather_by_city.dart';
import '../../domain/usecases/get_weather_by_location.dart';

/// Point d'injection de la couche `data` dans la présentation.
///
/// ⚠️ Ce provider est volontairement NON implémenté ici : la présentation ne
/// connaît que le contrat [WeatherRepository]. Il DOIT être surchargé au
/// démarrage, dans le `ProviderScope` racine (voir `main.dart`) :
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     weatherRepositoryProvider.overrideWithValue(
///       WeatherRepositoryImpl(
///         remoteDataSource: WeatherRemoteDataSourceImpl(http.Client()),
///         localDataSource: WeatherLocalDataSourceImpl(box),
///       ),
///     ),
///   ],
///   child: const WeatherPulseApp(),
/// )
/// ```
///
/// Les tests widget peuvent l'overrider avec un faux repository.
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  throw UnimplementedError(
    'weatherRepositoryProvider doit être surchargé dans le ProviderScope racine '
    '(main.dart) avec une implémentation de WeatherRepository.',
  );
});

/// Contrat minimal de géolocalisation attendu par l'écran principal (F04).
///
/// TODO(Géolocalisation): implémenter avec `geolocator`, gérer les trois cas de
/// permission (accordée / refusée / refusée définitivement) et surcharger
/// [locationServiceProvider] dans `main.dart`. En cas d'échec, lever une
/// [LocationFailure] (core/errors/failures.dart) : l'UI l'affiche telle quelle.
abstract class LocationService {
  Future<({double latitude, double longitude})> currentPosition();
}

final locationServiceProvider = Provider<LocationService>((ref) {
  throw UnimplementedError(
    'locationServiceProvider: à implémenter par la Géolocalisation (F04).',
  );
});

// ── Use cases (couche domain, déjà fournie) ────────────────────────────────────

final getWeatherByCityProvider = Provider<GetWeatherByCity>(
  (ref) => GetWeatherByCity(ref.watch(weatherRepositoryProvider)),
);

final getWeatherByLocationProvider = Provider<GetWeatherByLocation>(
  (ref) => GetWeatherByLocation(ref.watch(weatherRepositoryProvider)),
);
