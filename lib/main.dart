import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/weather/data/datasources/favorites_local_datasource.dart';
import 'features/weather/data/datasources/weather_local_datasource.dart';
import 'features/weather/data/datasources/weather_remote_datasource.dart';
import 'features/weather/data/repositories/favorites_repository_impl.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/presentation/pages/home_page.dart';
import 'features/weather/presentation/viewmodels/favorites_providers.dart';
import 'features/weather/presentation/viewmodels/weather_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charge les variables d'environnement depuis .env AVANT tout le reste.
  // Tolérant à l'absence du fichier (CI, ou premier lancement d'un membre) :
  // l'app démarre quand même, les appels API échoueront proprement via F03.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Cache local (feature bonus) : box ouverte une fois pour toute l'app.
  await Hive.initFlutter();
  final weatherBox = await Hive.openBox<String>(CacheConstants.weatherBoxName);
  final favoritesBox = await Hive.openBox<String>(FavoritesConstants.boxName);

  // TODO Membre E : initialiser Firebase ici (Firebase.initializeApp()).

  // Câblage de la couche `data` derrière le contrat WeatherRepository.
  // La présentation ne dépend que de `weatherRepositoryProvider` ; c'est le
  // seul endroit qui connaît les implémentations concrètes.
  final weatherRepository = WeatherRepositoryImpl(
    remoteDataSource: WeatherRemoteDataSourceImpl(http.Client()),
    localDataSource: WeatherLocalDataSourceImpl(weatherBox),
  );

  final favoritesRepository = FavoritesRepositoryImpl(
    localDataSource: FavoritesLocalDataSourceImpl(favoritesBox),
  );

  runApp(
    ProviderScope(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(weatherRepository),
        favoritesRepositoryProvider.overrideWithValue(favoritesRepository),
        // TODO(Géolocalisation): ajouter ici
        // locationServiceProvider.overrideWithValue(GeolocatorLocationService()).
      ],
      child: const WeatherPulseApp(),
    ),
  );
}

class WeatherPulseApp extends StatelessWidget {
  const WeatherPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
