import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charge les variables d'environnement depuis .env AVANT tout le reste
  await dotenv.load(fileName: '.env');

  // Init Hive pour le cache local (feature bonus)
  await Hive.initFlutter();
  await Hive.openBox<String>(CacheConstants.weatherBoxName);

  runApp(const ProviderScope(child: WeatherPulseApp()));
}

class WeatherPulseApp extends StatelessWidget {
  const WeatherPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('WeatherPulse 🌤️ — Setup OK')),
      ),
    );
  }
}
