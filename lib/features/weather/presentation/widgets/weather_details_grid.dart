import 'package:flutter/material.dart';

import '../../domain/entities/weather.dart';
import 'glass_card.dart';

/// Détails complémentaires (F05) : humidité, vent, ressenti — regroupés dans
/// une carte « verre dépoli », séparés par des filets verticaux.
class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Stat(
              icon: Icons.water_drop_rounded,
              value: '${weather.humidity}%',
              label: 'Humidité',
            ),
            const _Divider(),
            _Stat(
              icon: Icons.air_rounded,
              value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
              label: 'Vent',
            ),
            const _Divider(),
            _Stat(
              icon: Icons.thermostat_rounded,
              value: '${weather.feelsLike.round()}°',
              label: 'Ressenti',
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white.withValues(alpha: 0.22),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
