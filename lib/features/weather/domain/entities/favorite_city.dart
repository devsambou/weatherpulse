import 'package:equatable/equatable.dart';

/// Entité pure représentant une ville favorite enregistrée par l'utilisateur.
class FavoriteCity extends Equatable {
  final String cityName;
  final DateTime addedAt;

  const FavoriteCity({required this.cityName, required this.addedAt});

  @override
  List<Object?> get props => [cityName, addedAt];
}
