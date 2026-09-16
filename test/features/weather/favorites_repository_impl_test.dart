import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/data/datasources/favorites_local_datasource.dart';
import 'package:weatherpulse_g16/features/weather/data/models/favorite_city_model.dart';
import 'package:weatherpulse_g16/features/weather/data/repositories/favorites_repository_impl.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/favorite_city.dart';

// ---------------------------------------------------------------------------
// Mock manuel du datasource local Hive
// ---------------------------------------------------------------------------

class MockFavoritesLocalDataSource implements FavoritesLocalDataSource {
  final Map<String, FavoriteCityModel> _store = {};
  bool shouldThrow = false;
  String errorMessage = 'Erreur disque Hive';

  @override
  Future<void> addFavorite(FavoriteCityModel city) async {
    if (shouldThrow) throw Exception(errorMessage);
    _store[city.cityName.trim().toLowerCase()] = city;
  }

  @override
  Future<void> removeFavorite(String cityName) async {
    if (shouldThrow) throw Exception(errorMessage);
    _store.remove(cityName.trim().toLowerCase());
  }

  @override
  Future<List<FavoriteCityModel>> getFavorites() async {
    if (shouldThrow) throw Exception(errorMessage);
    final list = _store.values.toList();
    list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list;
  }

  @override
  Future<bool> isFavorite(String cityName) async {
    if (shouldThrow) throw Exception(errorMessage);
    return _store.containsKey(cityName.trim().toLowerCase());
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockFavoritesLocalDataSource mockDataSource;
  late FavoritesRepositoryImpl repository;

  final tDate = DateTime(2026, 3, 15, 12, 0);
  final tCity = FavoriteCity(cityName: 'Dakar', addedAt: tDate);

  setUp(() {
    mockDataSource = MockFavoritesLocalDataSource();
    repository = FavoritesRepositoryImpl(localDataSource: mockDataSource);
  });

  group('FavoritesRepositoryImpl - addFavorite', () {
    test('ajoute la ville avec succès et retourne Right(null)', () async {
      final result = await repository.addFavorite(tCity);

      expect(result, const Right(null));
      final favorites = await mockDataSource.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.cityName, 'Dakar');
    });

    test('ne crée pas de doublon si la ville est déjà en favori', () async {
      await repository.addFavorite(tCity);

      final secondCity = FavoriteCity(
        cityName: 'dakar', // Casse différente
        addedAt: DateTime(2026, 3, 15, 12, 30),
      );
      final result = await repository.addFavorite(secondCity);

      expect(result, const Right(null));
      final favorites = await mockDataSource.getFavorites();
      // Toujours une seule entrée pour Dakar
      expect(favorites.length, 1);
    });

    test(
      'retourne CacheFailure si le datasource local lève une exception',
      () async {
        mockDataSource.shouldThrow = true;

        final result = await repository.addFavorite(tCity);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Devrait être un Left'),
        );
      },
    );
  });

  group('FavoritesRepositoryImpl - removeFavorite', () {
    test('retire la ville des favoris avec succès', () async {
      await repository.addFavorite(tCity);
      expect((await mockDataSource.getFavorites()).length, 1);

      final result = await repository.removeFavorite('Dakar');

      expect(result, const Right(null));
      expect((await mockDataSource.getFavorites()).isEmpty, isTrue);
    });

    test('supprime la ville indépendamment de la casse', () async {
      await repository.addFavorite(tCity);

      final result = await repository.removeFavorite('dAkAr');

      expect(result, const Right(null));
      expect((await mockDataSource.getFavorites()).isEmpty, isTrue);
    });

    test('retourne CacheFailure en cas d\'erreur du datasource', () async {
      mockDataSource.shouldThrow = true;

      final result = await repository.removeFavorite('Dakar');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Devrait être un Left'),
      );
    });
  });

  group('FavoritesRepositoryImpl - getFavorites', () {
    test('retourne la liste triée des favoris', () async {
      final city1 = FavoriteCity(
        cityName: 'Paris',
        addedAt: DateTime(2026, 3, 15, 10, 0),
      );
      final city2 = FavoriteCity(
        cityName: 'Tokyo',
        addedAt: DateTime(2026, 3, 15, 11, 0),
      );

      await repository.addFavorite(city1);
      await repository.addFavorite(city2);

      final result = await repository.getFavorites();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Devrait être un Right'), (list) {
        expect(list.length, 2);
        // Le plus récent (Tokyo) en premier
        expect(list.first.cityName, 'Tokyo');
        expect(list.last.cityName, 'Paris');
      });
    });

    test(
      'retourne une liste vide quand aucun favori n\'est enregistré',
      () async {
        final result = await repository.getFavorites();

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Devrait être un Right'),
          (list) => expect(list, isEmpty),
        );
      },
    );

    test('retourne CacheFailure si une exception est levée', () async {
      mockDataSource.shouldThrow = true;

      final result = await repository.getFavorites();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Devrait être un Left'),
      );
    });
  });

  group('FavoritesRepositoryImpl - isFavorite', () {
    test('retourne Right(true) si la ville est dans les favoris', () async {
      await repository.addFavorite(tCity);

      final result = await repository.isFavorite('dakar');

      expect(result, const Right(true));
    });

    test(
      'retourne Right(false) si la ville n\'est pas dans les favoris',
      () async {
        final result = await repository.isFavorite('Londres');

        expect(result, const Right(false));
      },
    );

    test('retourne CacheFailure si une exception survient', () async {
      mockDataSource.shouldThrow = true;

      final result = await repository.isFavorite('Paris');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Devrait être un Left'),
      );
    });
  });
}
