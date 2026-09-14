import '../../domain/entities/forecast_day.dart';

/// Model de prévision journalière.
/// Sait parser et agréger les données brutes de l'endpoint /forecast d'OpenWeather
/// (40 tranches de 3h sur 5 jours → 5 résumés journaliers).
class ForecastModel extends ForecastDay {
  const ForecastModel({
    required super.date,
    required super.tempMin,
    required super.tempMax,
    required super.description,
    required super.iconCode,
    super.fetchedAt,
  });

  /// Agrège les 40 entrées de 3h de la réponse /forecast en 5 résumés journaliers.
  ///
  /// Logique d'agrégation :
  /// - Regroupement par date locale (yyyy-MM-dd)
  /// - tempMin = minimum des temp_min de chaque tranche
  /// - tempMax = maximum des temp_max de chaque tranche
  /// - description = description de la tranche du midi (12h), ou la plus fréquente
  /// - iconCode = icône de la tranche du midi (12h), ou la première du jour
  static List<ForecastModel> fromForecastJson(
    Map<String, dynamic> json, {
    DateTime? fetchedAt,
  }) {
    final list = json['list'] as List<dynamic>;
    final now = fetchedAt ?? DateTime.now();

    // Groupe les tranches par date (yyyy-MM-dd)
    final Map<String, List<Map<String, dynamic>>> byDay = {};
    for (final item in list) {
      final entry = item as Map<String, dynamic>;
      // dt_txt format : "2024-01-15 12:00:00"
      final dtTxt = entry['dt_txt'] as String;
      final dayKey = dtTxt.substring(0, 10); // "yyyy-MM-dd"
      byDay.putIfAbsent(dayKey, () => []).add(entry);
    }

    final result = <ForecastModel>[];

    // Trie les jours chronologiquement et génère un résumé par jour
    final sortedKeys = byDay.keys.toList()..sort();
    for (final dayKey in sortedKeys) {
      final entries = byDay[dayKey]!;

      double tempMin = double.infinity;
      double tempMax = double.negativeInfinity;

      // Tranche de midi (12:00) pour la description représentative
      Map<String, dynamic>? noonEntry;
      // Comptage des descriptions pour fallback
      final Map<String, int> descCount = {};

      for (final entry in entries) {
        final main = entry['main'] as Map<String, dynamic>;
        final min = (main['temp_min'] as num).toDouble();
        final max = (main['temp_max'] as num).toDouble();
        if (min < tempMin) tempMin = min;
        if (max > tempMax) tempMax = max;

        final dtTxt = entry['dt_txt'] as String;
        if (dtTxt.contains('12:00:00')) {
          noonEntry = entry;
        }

        final desc =
            (entry['weather'] as List<dynamic>)[0]['description'] as String;
        descCount[desc] = (descCount[desc] ?? 0) + 1;
      }

      // Description et icône : préférence midi, sinon la plus fréquente
      final representative = noonEntry ?? entries.first;
      final weatherArr = representative['weather'] as List<dynamic>;
      final description = weatherArr[0]['description'] as String;
      final iconCode = weatherArr[0]['icon'] as String;

      result.add(
        ForecastModel(
          date: DateTime.parse(dayKey),
          tempMin: tempMin == double.infinity ? 0 : tempMin,
          tempMax: tempMax == double.negativeInfinity ? 0 : tempMax,
          description: description,
          iconCode: iconCode,
          fetchedAt: now,
        ),
      );
    }

    return result;
  }

  /// Sérialise le modèle pour le stockage dans le cache local Hive
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'tempMin': tempMin,
    'tempMax': tempMax,
    'description': description,
    'iconCode': iconCode,
    'fetchedAt': (fetchedAt ?? DateTime.now()).toIso8601String(),
  };

  /// Reconstruit un ForecastModel depuis le cache local (Hive)
  factory ForecastModel.fromCacheJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: DateTime.parse(json['date'] as String),
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
      description: json['description'] as String,
      iconCode: json['iconCode'] as String,
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'] as String)
          : null,
    );
  }
}
