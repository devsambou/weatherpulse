import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/utils/fr_date.dart';

void main() {
  group('FrDate.greeting', () {
    test('retourne "Bonjour" pour les heures de matinée (5h à 11h59)', () {
      expect(FrDate.greeting(DateTime(2026, 9, 14, 5, 0)), 'Bonjour');
      expect(FrDate.greeting(DateTime(2026, 9, 14, 8, 30)), 'Bonjour');
      expect(FrDate.greeting(DateTime(2026, 9, 14, 11, 59)), 'Bonjour');
    });

    test('retourne "Bon après-midi" entre 12h00 et 17h59', () {
      expect(FrDate.greeting(DateTime(2026, 9, 14, 12, 0)), 'Bon après-midi');
      expect(FrDate.greeting(DateTime(2026, 9, 14, 14, 15)), 'Bon après-midi');
      expect(FrDate.greeting(DateTime(2026, 9, 14, 17, 59)), 'Bon après-midi');
    });

    test('retourne "Bonsoir" en soirée et nuit (18h00 à 04h59)', () {
      expect(FrDate.greeting(DateTime(2026, 9, 14, 18, 0)), 'Bonsoir');
      expect(FrDate.greeting(DateTime(2026, 9, 14, 22, 45)), 'Bonsoir');
      expect(FrDate.greeting(DateTime(2026, 9, 14, 0, 0)), 'Bonsoir');
      expect(FrDate.greeting(DateTime(2026, 9, 14, 4, 59)), 'Bonsoir');
    });
  });

  group('FrDate formatters existants', () {
    test('full formate correctement la date en français', () {
      final date = DateTime(2026, 9, 14, 10, 0); // Lundi 14 septembre
      expect(FrDate.full(date), 'lundi 14 septembre');
    });

    test('time formate les heures et minutes avec padding zéro', () {
      final date = DateTime(2026, 9, 14, 9, 5);
      expect(FrDate.time(date), '09:05');
    });
  });
}
