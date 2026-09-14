import '../../domain/entities/favorite_city.dart';

/// Modèle sérialisable pour stocker une ville favorite en JSON dans Hive.
class FavoriteCityModel extends FavoriteCity {
  const FavoriteCityModel({required super.cityName, required super.addedAt});

  factory FavoriteCityModel.fromEntity(FavoriteCity entity) {
    return FavoriteCityModel(
      cityName: entity.cityName,
      addedAt: entity.addedAt,
    );
  }

  factory FavoriteCityModel.fromJson(Map<String, dynamic> json) {
    return FavoriteCityModel(
      cityName: json['cityName'] as String? ?? '',
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'cityName': cityName,
    'addedAt': addedAt.toIso8601String(),
  };
}
