import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Initialise [dotenv] avec une valeur de test fictive avant les tests.
///
/// Doit être appelé dans [setUpAll] de tout groupe de tests qui accède à
/// [ApiConstants.apiKey] (et donc à `dotenv.env['OPENWEATHER_API_KEY']`).
///
/// La valeur utilisée (`TEST_OPENWEATHER_API_KEY`) est fictive et ne
/// correspond à aucune clé réelle. Elle permet de satisfaire l'initialisation
/// de [flutter_dotenv] sans effectuer de vraies requêtes réseau.
void setupTestEnvironment() {
  dotenv.testLoad(fileInput: 'OPENWEATHER_API_KEY=TEST_OPENWEATHER_API_KEY\n');
}
