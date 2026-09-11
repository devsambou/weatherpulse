import 'package:flutter/material.dart';

import '../../../../core/utils/weather_visuals.dart';

/// Grande icône météo de l'écran principal.
///
/// Rend un emoji (lisible, cohérent, disponible hors-ligne et en test).
/// TODO(Écran & UI / bonus): possibilité de basculer sur l'image officielle
/// OpenWeather (`https://openweathermap.org/img/wn/<code>@4x.png`) via
/// `Image.network` si l'équipe préfère les icônes de la marque.
class WeatherGlyph extends StatelessWidget {
  const WeatherGlyph({super.key, required this.iconCode, this.size = 120});

  final String iconCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Center(
        child: Text(
          WeatherVisuals.emoji(iconCode),
          style: TextStyle(fontSize: size * 0.82, height: 1),
        ),
      ),
    );
  }
}
