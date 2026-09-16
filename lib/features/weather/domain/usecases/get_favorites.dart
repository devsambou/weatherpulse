import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/favorite_city.dart';
import '../repositories/favorites_repository.dart';

/// Use case pour récupérer la liste des villes favorites (F07).
class GetFavorites {
  final FavoritesRepository repository;
  const GetFavorites(this.repository);

  Future<Either<Failure, List<FavoriteCity>>> call() {
    return repository.getFavorites();
  }
}
