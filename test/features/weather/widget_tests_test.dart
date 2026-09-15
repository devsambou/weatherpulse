import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';
import 'package:weatherpulse_g16/features/weather/presentation/widgets/forecast_toggle.dart';
import 'package:weatherpulse_g16/features/weather/presentation/widgets/glass_container.dart';
import 'package:weatherpulse_g16/features/weather/presentation/widgets/main_weather_card.dart';
import 'package:weatherpulse_g16/features/weather/presentation/widgets/weather_detail_card.dart';
import 'package:weatherpulse_g16/features/weather/presentation/widgets/weather_search_field.dart';

void main() {
  final tWeather = Weather(
    cityName: 'Dakar',
    temperature: 29.4,
    feelsLike: 31.2,
    description: 'ciel dégagé',
    iconCode: '01d',
    humidity: 72,
    windSpeed: 3.5,
    windDegree: 210,
    cloudiness: 20,
    pressure: 1012,
    visibility: 9500,
    fetchedAt: DateTime(2024, 7, 18, 14, 30),
    sunrise: DateTime(2024, 7, 18, 6, 45),
    sunset: DateTime(2024, 7, 18, 19, 30),
    rainVolume: 0.5,
    tempMin: 27.0,
    tempMax: 32.0,
  );

  group('GlassContainer', () {
    testWidgets('affiche son contenu enfant et applique les contraintes', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassContainer(child: Text('Glass content'))),
        ),
      );

      expect(find.text('Glass content'), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });

  group('MainWeatherCard', () {
    testWidgets('affiche la ville, les températures, le ressenti et min/max', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MainWeatherCard(weather: tWeather),
            ),
          ),
        ),
      );

      expect(find.text('Dakar'), findsOneWidget);
      expect(find.text('29°'), findsOneWidget);
      expect(find.text('Ciel dégagé'), findsOneWidget);
      expect(find.text('Ressenti 31°'), findsOneWidget);
      expect(find.text('Min 27°  •  Max 32°'), findsOneWidget);
    });

    testWidgets('déclenche onToggleFavorite lors du clic', (tester) async {
      var toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MainWeatherCard(
                weather: tWeather,
                isFavorite: false,
                onToggleFavorite: () => toggled = true,
              ),
            ),
          ),
        ),
      );

      final favButton = find.byType(IconButton);
      expect(favButton, findsOneWidget);
      await tester.tap(favButton);
      await tester.pump();

      expect(toggled, isTrue);
    });
  });

  group('WeatherDetailCard', () {
    testWidgets('affiche l\'icône, le label, la valeur et l\'unité', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDetailCard(
              icon: Icons.water_drop_rounded,
              label: 'Humidité',
              value: '72',
              unit: '%',
              subtitle: 'Point de rosée',
            ),
          ),
        ),
      );

      expect(find.text('Humidité'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.text('Point de rosée'), findsOneWidget);
    });
  });

  group('WeatherSearchField', () {
    testWidgets('saisit du texte et appelle onSubmitted sur validation', (
      tester,
    ) async {
      String? submittedQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherSearchField(
              onSubmitted: (query) => submittedQuery = query,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Abidjan');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedQuery, 'Abidjan');
    });

    testWidgets('ne déclenche pas onSubmitted si le champ est vide', (
      tester,
    ) async {
      String? submittedQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherSearchField(
              onSubmitted: (query) => submittedQuery = query,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, '   ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedQuery, isNull);
    });

    testWidgets('le bouton effacer vide le champ texte', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WeatherSearchField(onSubmitted: (_) {})),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Paris');
      await tester.pump();

      final clearButton = find.byTooltip('Effacer');
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pump();

      expect(find.text('Paris'), findsNothing);
    });

    testWidgets('affiche le message d\'erreur si fourni', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherSearchField(
              errorMessage: 'Ville introuvable.',
              onSubmitted: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Ville introuvable.'), findsOneWidget);
    });
  });

  group('ForecastToggle', () {
    testWidgets('bascule le mode lors du clic', (tester) async {
      ForecastViewMode selectedMode = ForecastViewMode.hourly;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ForecastToggle(
                selectedMode: selectedMode,
                onModeChanged: (newMode) =>
                    setState(() => selectedMode = newMode),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Par heure'), findsOneWidget);
      expect(find.text('Quotidien'), findsOneWidget);

      await tester.tap(find.text('Quotidien'));
      await tester.pumpAndSettle();

      expect(selectedMode, ForecastViewMode.daily);
    });
  });
}
