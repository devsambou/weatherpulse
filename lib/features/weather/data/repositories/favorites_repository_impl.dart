import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/favorite_city.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../models/favorite_city_model.dart';

/// Implémentation concrète de FavoritesRepository avec gestion des erreurs (F07).
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  const FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> addFavorite(FavoriteCity city) async {
    try {
      final model = FavoriteCityModel.fromEntity(city);
      await localDataSource.addFavorite(model);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Impossible d\'ajouter la ville aux favoris : $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String cityName) async {
    try {
      await localDataSource.removeFavorite(cityName);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Impossible de retirer la ville des favoris : $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<FavoriteCity>>> getFavorites() async {
    try {
      final list = await localDataSource.getFavorites();
      return Right(list);
    } catch (e) {
      return Left(CacheFailure('Impossible de charger les favoris : $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String cityName) async {
    try {
      final result = await localDataSource.isFavorite(cityName);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Impossible de vérifier le statut favori : $e'));
    }
  }
}
