import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/exceptions.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';

void main() {
  group('Failures', () {
    test('ServerFailure props et égalité', () {
      const f1 = ServerFailure('Erreur serveur');
      const f2 = ServerFailure('Erreur serveur');
      expect(f1, equals(f2));
      expect(f1.props, ['Erreur serveur']);
    });

    test('CacheFailure props et égalité', () {
      const f1 = CacheFailure('Cache vide');
      const f2 = CacheFailure('Cache vide');
      expect(f1, equals(f2));
    });

    test('LocationFailure props et égalité', () {
      const f1 = LocationFailure('Erreur GPS');
      const f2 = LocationFailure('Erreur GPS');
      expect(f1, equals(f2));
    });

    test('NetworkFailure props et égalité', () {
      const f1 = NetworkFailure('Pas de réseau');
      const f2 = NetworkFailure('Pas de réseau');
      expect(f1, equals(f2));
    });

    test('CityNotFoundFailure props et égalité', () {
      const f1 = CityNotFoundFailure('Ville inconnue');
      const f2 = CityNotFoundFailure('Ville inconnue');
      expect(f1, equals(f2));
    });

    test('QuotaExceededFailure props et égalité', () {
      const f1 = QuotaExceededFailure('Quota dépassé');
      const f2 = QuotaExceededFailure('Quota dépassé');
      expect(f1, equals(f2));
    });

    test('ServerErrorFailure props et égalité avec statusCode', () {
      const f1 = ServerErrorFailure('Erreur 500', statusCode: 500);
      const f2 = ServerErrorFailure('Erreur 500', statusCode: 500);
      expect(f1, equals(f2));
      expect(f1.props, ['Erreur 500', 500]);
      expect(f1.statusCode, 500);
    });
  });

  group('Exceptions', () {
    test('CityNotFoundException toString', () {
      const e = CityNotFoundException('Ville introuvable');
      expect(e.toString(), 'CityNotFoundException: Ville introuvable');
    });

    test('QuotaExceededException toString', () {
      const e = QuotaExceededException('Trop de requêtes');
      expect(e.toString(), 'QuotaExceededException: Trop de requêtes');
    });

    test('ServerException toString', () {
      const e = ServerException(statusCode: 502, message: 'Bad Gateway');
      expect(e.toString(), 'ServerException(502): Bad Gateway');
      expect(e.statusCode, 502);
    });

    test('NetworkException toString', () {
      const e = NetworkException('Pas de connexion');
      expect(e.toString(), 'NetworkException: Pas de connexion');
    });
  });
}
