import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_day.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_hour.dart';
import 'package:weatherpulse_g16/features/weather/presentation/widgets/forecast_hourly_section.dart';
import 'package:weatherpulse_g16/features/weather/presentation/widgets/forecast_toggle.dart';

void main() {
  final tHours = [
    ForecastHour(
      dateTime: DateTime(2024, 7, 18, 14, 0),
      temperature: 28.4,
      feelsLike: 30.1,
      description: 'ensoleillé',
      iconCode: '01d',
      pop: 0.25,
      windSpeed: 4.2,
      humidity: 60,
    ),
    ForecastHour(
      dateTime: DateTime(2024, 7, 18, 17, 0),
      temperature: 26.0,
      feelsLike: 27.0,
      description: 'ciel dégagé',
      iconCode: '01d',
      pop: 0.0,
      windSpeed: 3.5,
      humidity: 65,
    ),
  ];

  final tDays = [
    ForecastDay(
      date: DateTime(2024, 7, 19),
      tempMin: 22.0,
      tempMax: 31.0,
      description: 'ensoleillé',
      iconCode: '01d',
    ),
    ForecastDay(
      date: DateTime(2024, 7, 20),
      tempMin: 21.0,
      tempMax: 29.0,
      description: 'pluie légère',
      iconCode: '10d',
    ),
  ];

  group('ForecastHourlySection', () {
    testWidgets('affiche SizedBox.shrink si liste vide', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ForecastHourlySection(hours: [])),
        ),
      );
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('affiche les heures, températures et pluie si pop > 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ForecastHourlySection(hours: tHours)),
        ),
      );

      expect(find.text('14h'), findsOneWidget);
      expect(find.text('17h'), findsOneWidget);
      expect(find.text('28°'), findsOneWidget);
      expect(find.text('26°'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
    });
  });

  group('ForecastDailySection', () {
    testWidgets('affiche SizedBox.shrink si liste vide', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ForecastDailySection(days: [])),
        ),
      );
      expect(find.text('Lundi'), findsNothing);
    });

    testWidgets('affiche les jours, descriptions et températures min/max', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ForecastDailySection(days: tDays)),
        ),
      );

      expect(find.text('ensoleillé'), findsOneWidget);
      expect(find.text('pluie légère'), findsOneWidget);
      expect(find.text('22° / 31°'), findsOneWidget);
      expect(find.text('21° / 29°'), findsOneWidget);
    });
  });

  group('ForecastSectionView', () {
    testWidgets('affiche SizedBox.shrink si hours et days sont vides', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ForecastSectionView(hours: [], days: []),
          ),
        ),
      );
      expect(find.text('Prévisions'), findsNothing);
    });

    testWidgets(
      'affiche le titre, le toggle et bascule entre horaire et quotidien',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ForecastSectionView(hours: tHours, days: tDays),
              ),
            ),
          ),
        );

        expect(find.text('Prévisions'), findsOneWidget);
        expect(find.byType(ForecastToggle), findsOneWidget);
        expect(find.byType(ForecastHourlySection), findsOneWidget);

        // Bascule vers le mode quotidien via la Key stable du bouton "Quotidien"
        await tester.tap(find.byKey(const Key('forecast_daily_toggle')));
        await tester.pumpAndSettle();

        expect(find.byType(ForecastDailySection), findsOneWidget);
        expect(find.text('ensoleillé'), findsOneWidget);
      },
    );
  });
}
