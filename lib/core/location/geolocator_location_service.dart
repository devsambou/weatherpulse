import 'package:geolocator/geolocator.dart';

import '../errors/failures.dart';
import '../../features/weather/presentation/viewmodels/weather_providers.dart';

/// Implémentation concrète de [LocationService] basée sur le package
/// `geolocator` (F04 — Géolocalisation automatique).
///
/// Gère explicitement les trois cas exigés par le CDC :
///  - service de localisation désactivé sur l'appareil ;
///  - permission refusée (l'utilisateur peut réessayer) ;
///  - permission refusée définitivement (nécessite un aller-retour réglages).
///
/// Toute erreur est remontée sous forme de [LocationFailure] : l'UI
/// (`WeatherViewModel.loadFromDeviceLocation`) l'affiche telle quelle (F03),
/// sans jamais laisser fuiter une exception technique du package `geolocator`.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static const _serviceDisabledMessage =
      "La localisation est désactivée sur votre appareil. "
      "Activez-la dans les réglages pour afficher la météo de votre position.";

  static const _permissionDeniedMessage =
      "Autorisation de localisation refusée. Autorisez l'accès à votre "
      "position pour afficher la météo de votre position actuelle.";

  static const _permissionDeniedForeverMessage =
      "Autorisation de localisation refusée définitivement. Activez-la "
      "manuellement depuis les réglages de l'application.";

  static const _unavailableMessage =
      "Impossible de récupérer votre position pour le moment. Réessayez.";

  @override
  Future<({double latitude, double longitude})> currentPosition() async {
    // 1. Le service de localisation (GPS/réseau) doit être actif sur l'appareil.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(_serviceDisabledMessage);
    }

    // 2. Vérifie l'autorisation courante, puis la demande si nécessaire.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationFailure(_permissionDeniedMessage);
      }
    }

    // 3. Cas "refusée définitivement" : seul un réglage manuel peut débloquer.
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(_permissionDeniedForeverMessage);
    }

    // 4. Récupère la position avec un délai raisonnable pour ne pas bloquer l'UI
    //    indéfiniment si le GPS met du temps à obtenir un premier "fix".
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return (latitude: position.latitude, longitude: position.longitude);
    } on LocationServiceDisabledException {
      throw const LocationFailure(_serviceDisabledMessage);
    } catch (_) {
      throw const LocationFailure(_unavailableMessage);
    }
  }
}
