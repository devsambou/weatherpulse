import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/favorites_repository.dart';

/// Use case pour retirer une ville des favoris (F07).
class RemoveFavorite {
  final FavoritesRepository repository;
  const RemoveFavorite(this.repository);

  Future<Either<Failure, void>> call(String cityName) {
    return repository.removeFavorite(cityName);
  }
}
