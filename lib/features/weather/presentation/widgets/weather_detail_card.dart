import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/utils/fr_date.dart';
import '../../../../core/utils/weather_calculations.dart';
import '../../domain/entities/weather.dart';
import 'glass_container.dart';

/// Carte générique de détail météo (Fonctionnalité 3) avec glassmorphism.
class WeatherDetailCard extends StatelessWidget {
  const WeatherDetailCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.iconWidget,
    this.subtitle,
    this.trailing,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Widget? iconWidget;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // En-tête : icône + label
          Row(
            children: [
              if (iconWidget != null)
                iconWidget!
              else if (icon != null)
                Icon(
                  icon,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // ignore: use_null_aware_elements
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),

          // Valeur principale + unité
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Grille complète et responsive des cartes de détails météo (Fonctionnalité 3).
class WeatherDetailsEnrichedGrid extends StatelessWidget {
  const WeatherDetailsEnrichedGrid({super.key, required this.weather});

  final Weather weather;

  String _windDirection(int degree) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    final index = ((degree + 22.5) % 360 ~/ 45);
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    final dewPoint = calculateDewPoint(weather.temperature, weather.humidity);
    final moonPhase = getMoonPhase(weather.fetchedAt);
    final moonIcon = getMoonPhaseIcon(moonPhase);
    final visibilityKm = (weather.visibility / 1000).toStringAsFixed(1);
    final windDirection = _windDirection(weather.windDegree);

    final cards = <Widget>[
      // 1. Humidité
      WeatherDetailCard(
        icon: Icons.water_drop_rounded,
        label: 'Humidité',
        value: '${weather.humidity}',
        unit: '%',
        subtitle: 'Point de rosée : $dewPoint°C',
      ),

      // 2. Vent
      WeatherDetailCard(
        icon: Icons.air_rounded,
        label: 'Vent',
        value: weather.windSpeed.toStringAsFixed(1),
        unit: 'm/s',
        subtitle: 'Dir. $windDirection (${weather.windDegree}°)',
        trailing: Transform.rotate(
          angle: (weather.windDegree * math.pi / 180),
          child: const Icon(
            Icons.navigation_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),

      // 3. Pression atmosphérique
      WeatherDetailCard(
        icon: Icons.compress_rounded,
        label: 'Pression',
        value: '${weather.pressure}',
        unit: 'hPa',
        subtitle: weather.pressure > 1013 ? 'Haute pression' : 'Basse pression',
      ),

      // 4. Visibilité
      WeatherDetailCard(
        icon: Icons.visibility_rounded,
        label: 'Visibilité',
        value: visibilityKm,
        unit: 'km',
        subtitle: weather.visibility >= 10000 ? 'Très bonne' : 'Moyenne',
      ),

      // 5. Couverture nuageuse
      WeatherDetailCard(
        icon: Icons.cloud_rounded,
        label: 'Nuages',
        value: '${weather.cloudiness}',
        unit: '%',
        subtitle: weather.cloudiness < 20
            ? 'Ciel clair'
            : weather.cloudiness < 60
            ? 'Partiellement nuageux'
            : 'Très nuageux',
      ),

      // 6. Point de rosée
      WeatherDetailCard(
        icon: Icons.opacity_rounded,
        label: 'Point de rosée',
        value: '$dewPoint',
        unit: '°C',
        subtitle: 'Seuil de condensation',
      ),

      // 7. Lever du soleil
      WeatherDetailCard(
        icon: Icons.wb_sunny_rounded,
        label: 'Lever du soleil',
        value: FrDate.time(weather.sunrise),
        subtitle: 'Aube locale',
      ),

      // 8. Coucher du soleil
      WeatherDetailCard(
        icon: Icons.nightlight_round,
        label: 'Coucher du soleil',
        value: FrDate.time(weather.sunset),
        subtitle: 'Crépuscule local',
      ),

      // 9. Phase de lune
      WeatherDetailCard(
        iconWidget: Text(moonIcon, style: const TextStyle(fontSize: 16)),
        label: 'Phase de lune',
        value: moonPhase,
        subtitle: 'Cycle synodique (~29.5j)',
      ),

      // 10. Précipitations (si disponibles)
      if (weather.rainVolume != null)
        WeatherDetailCard(
          icon: Icons.grain_rounded,
          label: 'Précipitations (1h)',
          value: weather.rainVolume!.toStringAsFixed(1),
          unit: 'mm',
          subtitle: 'Dernière heure observée',
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Détermine le nombre de colonnes : 2 sur mobile, 3 ou 4 si grand écran
        final width = constraints.maxWidth;
        final crossAxisCount = width > 720 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: crossAxisCount >= 3 ? 1.5 : 1.35,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}
