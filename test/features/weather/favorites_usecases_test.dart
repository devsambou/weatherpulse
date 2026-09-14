import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/favorite_city.dart';
import 'package:weatherpulse_g16/features/weather/domain/repositories/favorites_repository.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/add_favorite.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/get_favorites.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/is_favorite.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/remove_favorite.dart';

// ---------------------------------------------------------------------------
// Mock manuel du FavoritesRepository
// ---------------------------------------------------------------------------

class MockFavoritesRepository implements FavoritesRepository {
  Either<Failure, void>? addResult;
  Either<Failure, void>? removeResult;
  Either<Failure, List<FavoriteCity>>? getResult;
  Either<Failure, bool>? isFavResult;

  String? lastAddedCity;
  String? lastRemovedCity;
  String? lastCheckedCity;

  @override
  Future<Either<Failure, void>> addFavorite(FavoriteCity city) async {
    lastAddedCity = city.cityName;
    return addResult ?? const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String cityName) async {
    lastRemovedCity = cityName;
    return removeResult ?? const Right(null);
  }

  @override
  Future<Either<Failure, List<FavoriteCity>>> getFavorites() async {
    return getResult ?? const Right(<FavoriteCity>[]);
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String cityName) async {
    lastCheckedCity = cityName;
    return isFavResult ?? const Right(false);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockFavoritesRepository mockRepository;
  final tDate = DateTime(2026, 3, 15);
  final tCity = FavoriteCity(cityName: 'Dakar', addedAt: tDate);

  setUp(() {
    mockRepository = MockFavoritesRepository();
  });

  group('AddFavorite UseCase', () {
    test('appelle repository.addFavorite avec l\'entité fournie', () async {
      final useCase = AddFavorite(mockRepository);

      final result = await useCase(tCity);

      expect(result, const Right(null));
      expect(mockRepository.lastAddedCity, 'Dakar');
    });

    test('propage les erreurs du repository', () async {
      mockRepository.addResult = const Left(CacheFailure('Erreur'));
      final useCase = AddFavorite(mockRepository);

      final result = await useCase(tCity);

      expect(result, const Left(CacheFailure('Erreur')));
    });
  });

  group('RemoveFavorite UseCase', () {
    test('appelle repository.removeFavorite avec le nom de ville', () async {
      final useCase = RemoveFavorite(mockRepository);

      final result = await useCase('Dakar');

      expect(result, const Right(null));
      expect(mockRepository.lastRemovedCity, 'Dakar');
    });

    test('propage les erreurs du repository', () async {
      mockRepository.removeResult = const Left(CacheFailure('Erreur'));
      final useCase = RemoveFavorite(mockRepository);

      final result = await useCase('Dakar');

      expect(result, const Left(CacheFailure('Erreur')));
    });
  });

  group('GetFavorites UseCase', () {
    test('appelle repository.getFavorites et retourne la liste', () async {
      final list = [tCity];
      mockRepository.getResult = Right(list);
      final useCase = GetFavorites(mockRepository);

      final result = await useCase();

      expect(result, Right(list));
    });

    test('propage les erreurs du repository', () async {
      mockRepository.getResult = const Left(CacheFailure('Erreur'));
      final useCase = GetFavorites(mockRepository);

      final result = await useCase();

      expect(result, const Left(CacheFailure('Erreur')));
    });
  });

  group('IsFavorite UseCase', () {
    test(
      'appelle repository.isFavorite et retourne le résultat booléen',
      () async {
        mockRepository.isFavResult = const Right(true);
        final useCase = IsFavorite(mockRepository);

        final result = await useCase('Dakar');

        expect(result, const Right(true));
        expect(mockRepository.lastCheckedCity, 'Dakar');
      },
    );

    test('propage les erreurs du repository', () async {
      mockRepository.isFavResult = const Left(CacheFailure('Erreur'));
      final useCase = IsFavorite(mockRepository);

      final result = await useCase('Dakar');

      expect(result, const Left(CacheFailure('Erreur')));
    });
  });
}
