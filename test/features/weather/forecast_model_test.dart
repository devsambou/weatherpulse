import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/data/models/forecast_model.dart';

/// JSON représentatif d'une vraie réponse OpenWeather /forecast (simplifié à 8 entrées)
const tForecastJson = {
  'cod': '200',
  'cnt': 8,
  'list': [
    // Jour 1 — 2024-01-15
    {
      'dt': 1705312800,
      'dt_txt': '2024-01-15 06:00:00',
      'main': {'temp': 10.0, 'temp_min': 8.0, 'temp_max': 12.0, 'humidity': 75},
      'weather': [
        {'description': 'nuageux', 'icon': '04d'},
      ],
    },
    {
      'dt': 1705323600,
      'dt_txt': '2024-01-15 09:00:00',
      'main': {'temp': 12.0, 'temp_min': 9.0, 'temp_max': 14.0, 'humidity': 70},
      'weather': [
        {'description': 'partiellement nuageux', 'icon': '03d'},
      ],
    },
    {
      'dt': 1705334400,
      'dt_txt': '2024-01-15 12:00:00',
      'main': {
        'temp': 15.0,
        'temp_min': 11.0,
        'temp_max': 17.0,
        'humidity': 60,
      },
      'weather': [
        {'description': 'ciel dégagé', 'icon': '01d'},
      ],
    },
    {
      'dt': 1705345200,
      'dt_txt': '2024-01-15 15:00:00',
      'main': {
        'temp': 14.0,
        'temp_min': 10.0,
        'temp_max': 16.0,
        'humidity': 65,
      },
      'weather': [
        {'description': 'légères pluies', 'icon': '10d'},
      ],
    },
    // Jour 2 — 2024-01-16
    {
      'dt': 1705399200,
      'dt_txt': '2024-01-16 06:00:00',
      'main': {'temp': 5.0, 'temp_min': 3.0, 'temp_max': 7.0, 'humidity': 90},
      'weather': [
        {'description': 'pluie modérée', 'icon': '10d'},
      ],
    },
    {
      'dt': 1705410000,
      'dt_txt': '2024-01-16 09:00:00',
      'main': {'temp': 6.0, 'temp_min': 4.0, 'temp_max': 8.0, 'humidity': 88},
      'weather': [
        {'description': 'pluie modérée', 'icon': '10d'},
      ],
    },
    {
      'dt': 1705420800,
      'dt_txt': '2024-01-16 12:00:00',
      'main': {'temp': 8.0, 'temp_min': 5.0, 'temp_max': 9.0, 'humidity': 80},
      'weather': [
        {'description': 'légères pluies', 'icon': '10d'},
      ],
    },
    {
      'dt': 1705431600,
      'dt_txt': '2024-01-16 15:00:00',
      'main': {'temp': 7.0, 'temp_min': 4.0, 'temp_max': 9.0, 'humidity': 82},
      'weather': [
        {'description': 'pluie modérée', 'icon': '10d'},
      ],
    },
  ],
  'city': {'name': 'Paris'},
};

void main() {
  group('ForecastModel', () {
    late List<ForecastModel> forecast;

    setUp(() {
      forecast = ForecastModel.fromForecastJson(
        Map<String, dynamic>.from(tForecastJson),
      );
    });

    test(
      'fromForecastJson retourne 2 jours pour un JSON à 8 entrées (2 jours)',
      () {
        expect(forecast.length, 2);
      },
    );

    test('le premier jour a la bonne date', () {
      expect(forecast[0].date, DateTime(2024, 1, 15));
    });

    test('tempMin du jour 1 est le minimum de toutes les tranches', () {
      // Les temp_min des tranches de jour 1 : 8, 9, 11, 10 → min = 8
      expect(forecast[0].tempMin, 8.0);
    });

    test('tempMax du jour 1 est le maximum de toutes les tranches', () {
      // Les temp_max des tranches de jour 1 : 12, 14, 17, 16 → max = 17
      expect(forecast[0].tempMax, 17.0);
    });

    test('la description du jour 1 vient de la tranche de midi (12h)', () {
      expect(forecast[0].description, 'ciel dégagé');
    });

    test("l'iconCode du jour 1 vient de la tranche de midi (12h)", () {
      expect(forecast[0].iconCode, '01d');
    });

    test('le second jour a la bonne date', () {
      expect(forecast[1].date, DateTime(2024, 1, 16));
    });

    test('tempMin du jour 2 est calculée correctement', () {
      // Les temp_min des tranches de jour 2 : 3, 4, 5, 4 → min = 3
      expect(forecast[1].tempMin, 3.0);
    });

    test('tempMax du jour 2 est calculée correctement', () {
      // Les temp_max des tranches de jour 2 : 7, 8, 9, 9 → max = 9
      expect(forecast[1].tempMax, 9.0);
    });

    test('ForecastModel est un ForecastDay (héritage respecté)', () {
      expect(forecast[0], isA<ForecastModel>());
    });

    test('les jours sont triés chronologiquement', () {
      for (var i = 0; i < forecast.length - 1; i++) {
        expect(forecast[i].date.isBefore(forecast[i + 1].date), isTrue);
      }
    });

    test('un JSON vide retourne une liste vide', () {
      final empty = ForecastModel.fromForecastJson({
        'list': [],
        'city': {'name': 'Empty'},
      });
      expect(empty, isEmpty);
    });
  });
}
