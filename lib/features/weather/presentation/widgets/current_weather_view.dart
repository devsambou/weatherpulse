import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fr_date.dart';
import '../../domain/entities/weather.dart';
import '../viewmodels/favorites_view_model.dart';
import 'weather_glyph.dart';

/// Bloc « héros » de l'écran principal (F05) : date, ville, icône,
/// grande température, condition et ressenti — posé sur le dégradé de fond.
class CurrentWeatherView extends StatelessWidget {
  const CurrentWeatherView({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final description = weather.description.isEmpty
        ? ''
        : '${weather.description[0].toUpperCase()}'
              '${weather.description.substring(1)}';

    return Column(
      children: [
        Text(
          FrDate.full(weather.fetchedAt),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.place_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                weather.cityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _FavoriteToggleButton(cityName: weather.cityName),
          ],
        ),
        const SizedBox(height: 12),
        WeatherGlyph(iconCode: weather.iconCode, size: 140),
        const SizedBox(height: 4),
        Text(
          '${weather.temperature.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 96,
            fontWeight: FontWeight.w200,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          'Ressenti ${weather.feelsLike.round()}°',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _FavoriteToggleButton extends ConsumerWidget {
  const _FavoriteToggleButton({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesViewModelProvider).value ?? [];
    final isFav = favorites.any(
      (c) => c.cityName.toLowerCase() == cityName.trim().toLowerCase(),
    );

    return IconButton(
      tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
      icon: Icon(
        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFav ? Colors.redAccent : Colors.white.withValues(alpha: 0.85),
        size: 24,
      ),
      onPressed: () {
        ref.read(favoritesViewModelProvider.notifier).toggleFavorite(cityName);
      },
    );
  }
}
