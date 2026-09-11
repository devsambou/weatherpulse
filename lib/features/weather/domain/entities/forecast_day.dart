import 'package:equatable/equatable.dart';

/// Entité pure du domaine représentant un résumé journalier des prévisions.
/// Ne contient aucune dépendance à l'API ou au JSON.
class ForecastDay extends Equatable {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;

  const ForecastDay({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
  });

  @override
  List<Object> get props => [date, tempMin, tempMax, description, iconCode];
}
