import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Exécuté automatiquement par `flutter test` avant chaque fichier de test.
///
/// Initialise `dotenv` avec une clé factice : `ApiConstants.apiKey` lit
/// `dotenv.env`, qui lève sinon une `NotInitializedError` puisque les tests
/// ne passent jamais par `main()` (donc jamais par `dotenv.load('.env')`).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  dotenv.testLoad(mergeWith: {'OPENWEATHER_API_KEY': 'test_api_key'});
  await testMain();
}
