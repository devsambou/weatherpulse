import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/favorites_repository.dart';

/// Use case pour vérifier si une ville est déjà dans les favoris (F07).
class IsFavorite {
  final FavoritesRepository repository;
  const IsFavorite(this.repository);

  Future<Either<Failure, bool>> call(String cityName) {
    return repository.isFavorite(cityName);
  }
}
