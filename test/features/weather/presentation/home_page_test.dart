import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/presentation/pages/home_page.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_providers.dart';
import 'package:weatherpulse_g16/features/weather/presentation/widgets/current_weather_view.dart';

import '../../../helpers/fake_weather_repository.dart';

/// Trouve un texte affiché dans le bloc météo, en excluant le champ de
/// recherche (qui conserve la dernière saisie et peut porter le même texte).
Finder _inHero(String text) => find.descendant(
  of: find.byType(CurrentWeatherView),
  matching: find.text(text),
);

Future<void> _searchCity(WidgetTester tester, String city) async {
  await tester.enterText(find.byType(TextField), city);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();
}

void main() {
  group('HomePage', () {
    testWidgets('affiche l\'état vide au démarrage (F05)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherRepositoryProvider.overrideWithValue(
              FakeWeatherRepository(),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pump(); // laisse `build()` résoudre l'état initial (null)

      expect(
        find.text('Recherchez une ville pour afficher sa météo.'),
        findsOneWidget,
      );
    });

    testWidgets('affiche la météo après recherche d\'une ville (F01/F05)', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherRepositoryProvider.overrideWithValue(
              FakeWeatherRepository(),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      await _searchCity(tester, 'Dakar');

      expect(_inHero('Dakar'), findsOneWidget);
      expect(_inHero('27°'), findsOneWidget);
      expect(_inHero('Ressenti 29°'), findsOneWidget);
      expect(find.text('55%'), findsOneWidget); // humidité
    });

    testWidgets(
      'affiche un message clair et « Réessayer » en cas d\'erreur (F03)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              weatherRepositoryProvider.overrideWithValue(
                FakeWeatherRepository(shouldFail: true),
              ),
            ],
            child: const MaterialApp(home: HomePage()),
          ),
        );

        await _searchCity(tester, 'Atlantide');

        expect(find.text('Pas de connexion internet.'), findsOneWidget);
        expect(find.text('Réessayer'), findsOneWidget);
      },
    );
  });
}
