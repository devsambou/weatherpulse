import 'dart:math' as math;

/// Calcul du point de rosée (dew point) en °C via l'approximation de Magnus-Tetens.
///
/// [temperatureCelsius] : température de l'air en °C.
/// [humidityPercent] : humidité relative en % (1 à 100).
/// Retourne la température du point de rosée en °C arrondie à une décimale.
double calculateDewPoint(double temperatureCelsius, int humidityPercent) {
  // Bornage de l'humidité relative pour éviter ln(<=0)
  final rh = humidityPercent.clamp(1, 100);
  const a = 17.27;
  const b = 237.7;

  final alpha =
      ((a * temperatureCelsius) / (b + temperatureCelsius)) +
      math.log(rh / 100.0);
  final dewPoint = (b * alpha) / (a - alpha);

  return double.parse(dewPoint.toStringAsFixed(1));
}

/// Calcul astronomique de la phase de la lune basée sur le cycle synodique (~29.53 jours).
///
/// Utilise une nouvelle lune de référence connue (6 janvier 2000 à 18:14 UTC).
/// Retourne le nom en français de la phase (ex: "Nouvelle lune", "Pleine lune", etc.).
String getMoonPhase(DateTime date) {
  final utcDate = date.toUtc();
  // Référence d'une nouvelle lune astronomique connue
  final refNewMoon = DateTime.utc(2000, 1, 6, 18, 14);

  final diffDays =
      utcDate.difference(refNewMoon).inMilliseconds / (86400.0 * 1000.0);
  const synodicMonth = 29.53058867;

  var phaseDay = diffDays % synodicMonth;
  if (phaseDay < 0) {
    phaseDay += synodicMonth;
  }

  // 8 phases lunaires réparties sur les ~29.53 jours (environ 3.69 jours par intervalle)
  if (phaseDay < 1.84 || phaseDay >= 27.69) {
    return 'Nouvelle lune';
  } else if (phaseDay < 5.53) {
    return 'Premier croissant';
  } else if (phaseDay < 9.23) {
    return 'Premier quartier';
  } else if (phaseDay < 12.92) {
    return 'Gibbeuse croissante';
  } else if (phaseDay < 16.61) {
    return 'Pleine lune';
  } else if (phaseDay < 20.30) {
    return 'Gibbeuse décroissante';
  } else if (phaseDay < 23.99) {
    return 'Dernier quartier';
  } else {
    return 'Dernier croissant';
  }
}

/// Icône ou glyphe représentatif de la phase lunaire.
String getMoonPhaseIcon(String phase) {
  switch (phase) {
    case 'Nouvelle lune':
      return '🌑';
    case 'Premier croissant':
      return '🌒';
    case 'Premier quartier':
      return '🌓';
    case 'Gibbeuse croissante':
      return '🌔';
    case 'Pleine lune':
      return '🌕';
    case 'Gibbeuse décroissante':
      return '🌖';
    case 'Dernier quartier':
      return '🌗';
    case 'Dernier croissant':
      return '🌘';
    default:
      return '🌙';
  }
}
