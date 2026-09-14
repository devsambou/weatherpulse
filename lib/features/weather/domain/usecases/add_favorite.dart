import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/favorite_city.dart';
import '../repositories/favorites_repository.dart';

/// Use case pour ajouter une ville aux favoris (F07).
class AddFavorite {
  final FavoritesRepository repository;
  const AddFavorite(this.repository);

  Future<Either<Failure, void>> call(FavoriteCity city) {
    return repository.addFavorite(city);
  }
}
