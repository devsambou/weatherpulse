import 'package:flutter/material.dart';

import '../../../../core/utils/weather_visuals.dart';

/// Grande icône météo de l'écran principal.
///
/// Rend une icône Material (via [WeatherVisuals.icon]) cohérente avec la condition.
/// L'utilisation d'icônes vectorielles évite la dépendance aux polices emoji
/// (ex. Noto Color Emoji) absentes dans certains environnements.
class WeatherGlyph extends StatelessWidget {
  const WeatherGlyph({super.key, required this.iconCode, this.size = 120});

  final String iconCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Center(
        child: Icon(
          WeatherVisuals.icon(iconCode),
          size: size * 0.78,
          color: Colors.white,
        ),
      ),
    );
  }
}
