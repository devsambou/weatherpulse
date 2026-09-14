import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/is_favorite.dart';
import '../../domain/usecases/remove_favorite.dart';

/// Point d'injection de la couche `data` pour les favoris.
///
/// Doit être surchargé au démarrage dans le `ProviderScope` racine (`main.dart`) :
/// ```dart
/// favoritesRepositoryProvider.overrideWithValue(favoritesRepository)
/// ```
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  throw UnimplementedError(
    'favoritesRepositoryProvider doit être surchargé dans le ProviderScope racine '
    '(main.dart) avec une implémentation de FavoritesRepository.',
  );
});

// ── Use cases (couche domain) ──────────────────────────────────────────────

final addFavoriteProvider = Provider<AddFavorite>(
  (ref) => AddFavorite(ref.watch(favoritesRepositoryProvider)),
);

final removeFavoriteProvider = Provider<RemoveFavorite>(
  (ref) => RemoveFavorite(ref.watch(favoritesRepositoryProvider)),
);

final getFavoritesProvider = Provider<GetFavorites>(
  (ref) => GetFavorites(ref.watch(favoritesRepositoryProvider)),
);

final isFavoriteProvider = Provider<IsFavorite>(
  (ref) => IsFavorite(ref.watch(favoritesRepositoryProvider)),
);
