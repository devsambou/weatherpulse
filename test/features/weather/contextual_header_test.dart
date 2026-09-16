import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';
import 'package:weatherpulse_g16/features/weather/presentation/widgets/contextual_header.dart';

void main() {
  Widget buildTestWidget({Weather? weather, DateTime? now}) {
    return MaterialApp(
      home: Scaffold(
        body: ContextualHeader(weather: weather, now: now),
      ),
    );
  }

  group('ContextualHeader Widget', () {
    testWidgets('affiche "Bonjour !" le matin', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(now: DateTime(2026, 9, 14, 9, 0)),
      );

      expect(find.text('Bonjour !'), findsOneWidget);
      expect(find.text('WEATHERPULSE'), findsOneWidget);
      expect(
        find.text('Recherchez une ville pour afficher la météo'),
        findsOneWidget,
      );
    });

    testWidgets('affiche "Bon après-midi !" l\'après-midi', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(now: DateTime(2026, 9, 14, 15, 30)),
      );

      expect(find.text('Bon après-midi !'), findsOneWidget);
    });

    testWidgets(
      'affiche "Bonsoir !" le soir avec la ville et l\'heure de mise à jour',
      (tester) async {
        final weather = Weather(
          cityName: 'Dakar',
          temperature: 27.0,
          feelsLike: 29.0,
          description: 'ciel dégagé',
          iconCode: '01n',
          humidity: 70,
          windSpeed: 4.0,
          fetchedAt: DateTime(2026, 9, 14, 20, 15),
          sunrise: DateTime(2026, 9, 14, 6, 30),
          sunset: DateTime(2026, 9, 14, 18, 45),
        );

        await tester.pumpWidget(
          buildTestWidget(weather: weather, now: DateTime(2026, 9, 14, 20, 30)),
        );

        expect(find.text('Bonsoir !'), findsOneWidget);
        expect(find.text('Dakar • Mis à jour à 20:15'), findsOneWidget);
      },
    );

    testWidgets('le bouton paramètres n\'est plus présent dans le header', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      final settingsButton = find.byIcon(Icons.settings_outlined);
      expect(settingsButton, findsNothing);
    });
  });
}
