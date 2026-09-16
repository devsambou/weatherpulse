import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/utils/weather_calculations.dart';

void main() {
  group('calculateDewPoint', () {
    test('retourne la même température quand humidité = 100%', () {
      final dew = calculateDewPoint(20.0, 100);
      expect(dew, 20.0);
    });

    test('calcule le point de rosée pour 20°C et 50% d\'humidité (~9.3°C)', () {
      final dew = calculateDewPoint(20.0, 50);
      expect(dew, inInclusiveRange(9.1, 9.4));
    });

    test(
      'calcule le point de rosée pour 30°C et 70% d\'humidité (~24.0°C)',
      () {
        final dew = calculateDewPoint(30.0, 70);
        expect(dew, inInclusiveRange(23.7, 24.3));
      },
    );

    test('gère les températures négatives', () {
      final dew = calculateDewPoint(-5.0, 80);
      expect(dew, lessThan(-5.0));
    });

    test('borne les valeurs extrêmes d\'humidité sans planter', () {
      expect(() => calculateDewPoint(25.0, 0), returnsNormally);
      expect(() => calculateDewPoint(25.0, 105), returnsNormally);
    });
  });

  group('getMoonPhase', () {
    test('calcule Nouvelle lune pour une date connue (11 janvier 2024)', () {
      // Nouvelle lune astronomique : 11 janvier 2024 ~11:57 UTC
      final date = DateTime.utc(2024, 1, 11, 12, 0);
      final phase = getMoonPhase(date);
      expect(phase, 'Nouvelle lune');
    });

    test('calcule Pleine lune pour une date connue (25 janvier 2024)', () {
      // Pleine lune : ~14 jours après le 11 janvier 2024
      final date = DateTime.utc(2024, 1, 25, 18, 0);
      final phase = getMoonPhase(date);
      expect(phase, 'Pleine lune');
    });

    test('getMoonPhaseIcon retourne un emoji lune valide', () {
      expect(getMoonPhaseIcon('Nouvelle lune'), '🌑');
      expect(getMoonPhaseIcon('Pleine lune'), '🌕');
      expect(getMoonPhaseIcon('Premier quartier'), '🌓');
    });
  });
}
