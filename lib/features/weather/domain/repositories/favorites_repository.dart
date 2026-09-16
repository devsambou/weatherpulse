import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/favorite_city.dart';

/// Contrat abstrait pour la gestion des villes favorites (F07).
abstract class FavoritesRepository {
  Future<Either<Failure, void>> addFavorite(FavoriteCity city);
  Future<Either<Failure, void>> removeFavorite(String cityName);
  Future<Either<Failure, List<FavoriteCity>>> getFavorites();
  Future<Either<Failure, bool>> isFavorite(String cityName);
}
