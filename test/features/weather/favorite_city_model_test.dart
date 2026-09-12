import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/data/models/favorite_city_model.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/favorite_city.dart';

void main() {
  final tDate = DateTime(2026, 3, 15, 10, 30);
  final tJson = {'cityName': 'Dakar', 'addedAt': tDate.toIso8601String()};

  group('FavoriteCityModel', () {
    test('fromJson convertit correctement un Map valide', () {
      final model = FavoriteCityModel.fromJson(tJson);

      expect(model.cityName, 'Dakar');
      expect(model.addedAt, tDate);
    });

    test('toJson produit le Map attendu', () {
      final model = FavoriteCityModel(cityName: 'Paris', addedAt: tDate);
      final json = model.toJson();

      expect(json['cityName'], 'Paris');
      expect(json['addedAt'], tDate.toIso8601String());
    });

    test('fromEntity copie fidèlement les champs de l\'entité', () {
      final entity = FavoriteCity(cityName: 'Tokyo', addedAt: tDate);
      final model = FavoriteCityModel.fromEntity(entity);

      expect(model.cityName, entity.cityName);
      expect(model.addedAt, entity.addedAt);
      expect(model, isA<FavoriteCity>());
    });

    test('supporte l\'égalité via Equatable', () {
      final a = FavoriteCityModel(cityName: 'Rome', addedAt: tDate);
      final b = FavoriteCityModel(cityName: 'Rome', addedAt: tDate);

      expect(a, equals(b));
    });
  });
}
