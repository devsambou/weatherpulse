import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/core/navigation/app_shell.dart';
import 'package:weatherpulse_g16/features/settings/domain/repositories/settings_repository.dart';
import 'package:weatherpulse_g16/features/settings/presentation/viewmodels/settings_providers.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/favorite_city.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_day.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_hour.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';
import 'package:weatherpulse_g16/features/weather/domain/repositories/favorites_repository.dart';
import 'package:weatherpulse_g16/features/weather/domain/repositories/weather_repository.dart';
import 'package:weatherpulse_g16/features/weather/presentation/pages/favorites_page.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/favorites_providers.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_providers.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_view_model.dart';

// ---------------------------------------------------------------------------
// Faux Repositories pour les tests de widgets
// ---------------------------------------------------------------------------

class FakeFavoritesRepository implements FavoritesRepository {
  List<FavoriteCity> cities;
  FakeFavoritesRepository({List<FavoriteCity>? initial})
    : cities = initial ?? [];

  int addCalls = 0;
  int removeCalls = 0;

  @override
  Future<Either<Failure, void>> addFavorite(FavoriteCity city) async {
    addCalls++;
    cities.add(city);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String cityName) async {
    removeCalls++;
    cities.removeWhere(
      (c) => c.cityName.toLowerCase() == cityName.toLowerCase(),
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<FavoriteCity>>> getFavorites() async {
    return Right(List.unmodifiable(cities));
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String cityName) async {
    return Right(
      cities.any((c) => c.cityName.toLowerCase() == cityName.toLowerCase()),
    );
  }
}

class FakeWeatherRepository implements WeatherRepository {
  int fetchWeatherCalls = 0;
  String? lastFetchedCity;

  final Weather sampleWeather = Weather(
    cityName: 'Dakar',
    temperature: 28.0,
    feelsLike: 30.0,
    description: 'Ensoleillé',
    iconCode: '01d',
    humidity: 60,
    windSpeed: 4.5,
    fetchedAt: DateTime(2026, 3, 15, 12, 0),
    sunrise: DateTime(2026, 3, 15, 6, 30),
    sunset: DateTime(2026, 3, 15, 19, 0),
  );

  @override
  Future<Either<Failure, Weather>> getWeatherByCity(String city) async {
    fetchWeatherCalls++;
    lastFetchedCity = city;
    return Right(
      Weather(
        cityName: city,
        temperature: 25.0,
        feelsLike: 26.0,
        description: 'Clair',
        iconCode: '01d',
        humidity: 50,
        windSpeed: 3.0,
        fetchedAt: DateTime(2026, 3, 15, 12, 0),
        sunrise: DateTime(2026, 3, 15, 6, 30),
        sunset: DateTime(2026, 3, 15, 19, 0),
      ),
    );
  }

  @override
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    return Right(sampleWeather);
  }

  @override
  Future<Either<Failure, List<ForecastDay>>> getForecastByCity(
    String city,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<ForecastHour>>> getForecastHoursByCity(
    String city,
  ) async {
    return const Right([]);
  }
}

class FakeSettingsRepository implements SettingsRepository {
  ThemeMode mode = ThemeMode.system;

  @override
  ThemeMode getThemeMode() => mode;

  @override
  Future<void> saveThemeMode(ThemeMode newMode) async {
    mode = newMode;
  }
}

void main() {
  late FakeFavoritesRepository fakeFavRepo;
  late FakeWeatherRepository fakeWeatherRepo;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    fakeFavRepo = FakeFavoritesRepository(
      initial: [
        FavoriteCity(cityName: 'Paris', addedAt: DateTime(2026, 3, 15, 10, 0)),
        FavoriteCity(cityName: 'Tokyo', addedAt: DateTime(2026, 3, 15, 11, 0)),
      ],
    );
    fakeWeatherRepo = FakeWeatherRepository();
    fakeSettingsRepo = FakeSettingsRepository();
  });

  Widget createTestWidget({Widget? child}) {
    return ProviderScope(
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(fakeFavRepo),
        weatherRepositoryProvider.overrideWithValue(fakeWeatherRepo),
        settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
      ],
      child: MaterialApp(home: child ?? const AppShell()),
    );
  }

  group('AppShell & Navigation', () {
    testWidgets('affiche une seule NavigationBar avec les 3 destinations', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Vérifie la présence d'une seule NavigationBar dans tout l'arbre
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Favoris'), findsOneWidget);
      expect(find.text('Paramètres'), findsOneWidget);

      // IndexedStack est utilisé
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('la sélection d\'un onglet bascule l\'écran via IndexedStack', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Par défaut sur Accueil (index 0)
      final indexedStackFinder = find.byType(IndexedStack);
      IndexedStack stack = tester.widget(indexedStackFinder);
      expect(stack.index, 0);

      // Clic sur l'onglet Favoris
      await tester.tap(find.text('Favoris'));
      await tester.pumpAndSettle();

      stack = tester.widget(indexedStackFinder);
      expect(stack.index, 1);
      expect(find.text('Villes Favorites'), findsOneWidget);

      // Clic sur l'onglet Paramètres
      await tester.tap(find.text('Paramètres'));
      await tester.pumpAndSettle();

      stack = tester.widget(indexedStackFinder);
      expect(stack.index, 2);
      expect(find.text('APPARENCE'), findsOneWidget);
    });
  });

  group('FavoritesPage', () {
    testWidgets('affiche la liste des villes favorites', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const FavoritesPage()));
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Tokyo'), findsOneWidget);
    });

    testWidgets('affiche l\'état vide si aucun favori n\'est présent', (
      tester,
    ) async {
      fakeFavRepo.cities.clear();

      await tester.pumpWidget(createTestWidget(child: const FavoritesPage()));
      await tester.pumpAndSettle();

      expect(find.text('Aucune ville favorite'), findsOneWidget);
      expect(find.text('Suggestions rapides :'), findsOneWidget);
    });

    testWidgets(
      'la sélection d\'une ville favorite charge la météo et bascule à l\'Accueil',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Va sur l'onglet Favoris
        await tester.tap(find.text('Favoris'));
        await tester.pumpAndSettle();

        // Clique sur la tuile Paris
        await tester.tap(find.text('Paris'));
        await tester.pumpAndSettle();

        // Vérifie le basculement vers l'Accueil
        final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
        expect(stack.index, 0);

        // Vérifie l'appel météo pour Paris
        expect(fakeWeatherRepo.lastFetchedCity, 'Paris');
        expect(fakeWeatherRepo.fetchWeatherCalls, 1);
      },
    );

    testWidgets('évite une requête réseau si la ville est déjà active', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Charge d'abord Paris
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AppShell)),
      );
      await container
          .read(weatherViewModelProvider.notifier)
          .loadByCity('Paris');
      await tester.pumpAndSettle();
      expect(fakeWeatherRepo.fetchWeatherCalls, 1);

      // Bascule sur Favoris
      await tester.tap(find.text('Favoris'));
      await tester.pumpAndSettle();

      // Clique sur Paris qui est DÉJÀ chargée
      await tester.tap(find.text('Paris'));
      await tester.pumpAndSettle();

      // Toujours 1 seul appel API (aucune requête inutile !)
      expect(fakeWeatherRepo.fetchWeatherCalls, 1);
      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 0);
    });

    testWidgets('la suppression d\'un favori appelle removeCity', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(child: const FavoritesPage()));
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNWidgets(2));

      // Clique sur la première corbeille
      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();

      expect(fakeFavRepo.removeCalls, 1);
    });

    testWidgets(
      'l\'écran principal n\'affiche pas les villes par défaut (Paris, Tokyo, Dakar, New York)',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Aucune ville par défaut ne doit être visible sur l'écran d'accueil
        // Paris et Tokyo sont dans les favoris mais uniquement dans la page Favoris
        // L'accueil n'affiche pas de barre de villes prédéfinies
        expect(find.text('Dakar'), findsNothing);
        expect(find.text('New York'), findsNothing);

        // L'écran d'accueil affiche uniquement la vue vide (aucune ville chargée)
        expect(find.byType(IndexedStack), findsOneWidget);
        final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
        expect(stack.index, 0);
      },
    );

    testWidgets(
      'cliquer sur le cœur ajoute directement la ville dans l\'onglet Favoris',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Charge une ville via la recherche
        final container = ProviderScope.containerOf(
          tester.element(find.byType(AppShell)),
        );
        await container
            .read(weatherViewModelProvider.notifier)
            .loadByCity('Bamako');
        await tester.pumpAndSettle();

        // La ville est affichée dans la carte météo
        expect(find.text('Bamako'), findsOneWidget);

        // Clique sur le cœur pour ajouter aux favoris
        final heartButton = find.byIcon(Icons.favorite_border_rounded);
        expect(heartButton, findsOneWidget);
        await tester.tap(heartButton);
        await tester.pumpAndSettle();

        // Vérifie que Bamako a été ajouté au repository des favoris
        expect(fakeFavRepo.addCalls, 1);
        expect(fakeFavRepo.cities.any((c) => c.cityName == 'Bamako'), isTrue);

        // La ville n'apparaît qu'une seule fois dans l'écran principal (dans la carte météo)
        expect(find.text('Bamako'), findsOneWidget);

        // Bascule vers l'onglet Favoris
        await tester.tap(find.text('Favoris'));
        await tester.pumpAndSettle();

        // Vérifie que Bamako est bien présent dans l'onglet Favoris
        expect(find.text('Bamako'), findsOneWidget);
      },
    );
  });
}
