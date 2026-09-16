import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:weatherpulse_g16/features/weather/data/datasources/favorites_local_datasource.dart';
import 'package:weatherpulse_g16/features/weather/data/models/favorite_city_model.dart';

class FakeFavoritesBox extends Fake implements Box<String> {
  final Map<dynamic, String> _storage = {};

  @override
  Iterable<String> get values => _storage.values;

  @override
  Future<void> put(dynamic key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _storage.remove(key);
  }

  @override
  bool containsKey(dynamic key) => _storage.containsKey(key);
}

void main() {
  late FakeFavoritesBox fakeBox;
  late FavoritesLocalDataSourceImpl dataSource;

  setUp(() {
    fakeBox = FakeFavoritesBox();
    dataSource = FavoritesLocalDataSourceImpl(fakeBox);
  });

  final tCity1 = FavoriteCityModel(
    cityName: 'Paris',
    addedAt: DateTime(2024, 1, 1, 10, 0),
  );

  final tCity2 = FavoriteCityModel(
    cityName: 'Tokyo',
    addedAt: DateTime(2024, 1, 2, 10, 0),
  );

  group('FavoritesLocalDataSourceImpl', () {
    test(
      'addFavorite ajoute une ville dans la box en clé normalisée',
      () async {
        await dataSource.addFavorite(tCity1);
        expect(await dataSource.isFavorite('paris'), isTrue);
        expect(await dataSource.isFavorite(' Paris '), isTrue);
      },
    );

    test('removeFavorite supprime la ville de la box', () async {
      await dataSource.addFavorite(tCity1);
      expect(await dataSource.isFavorite('Paris'), isTrue);

      await dataSource.removeFavorite('Paris');
      expect(await dataSource.isFavorite('Paris'), isFalse);
    });

    test(
      'getFavorites retourne les villes triées par date décroissante',
      () async {
        await dataSource.addFavorite(tCity1);
        await dataSource.addFavorite(tCity2);

        final result = await dataSource.getFavorites();
        expect(result.length, 2);
        expect(result.first.cityName, 'Tokyo');
        expect(result.last.cityName, 'Paris');
      },
    );

    test(
      'isFavorite retourne false si la ville n\'est pas dans les favoris',
      () async {
        final result = await dataSource.isFavorite('Rome');
        expect(result, isFalse);
      },
    );
  });
}
