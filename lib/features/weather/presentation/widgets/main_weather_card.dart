import 'package:flutter/material.dart';
import '../../../../core/utils/fr_date.dart';
import '../../domain/entities/weather.dart';
import 'glass_container.dart';
import 'weather_glyph.dart';

/// Carte météo principale (Fonctionnalité 1) avec effet glassmorphism.
///
/// Affiche :
/// - Ville et date
/// - Température actuelle
/// - Icône météo (OpenWeather ou emoji de repli)
/// - Description de la météo
/// - Températures minimale et maximale
/// - Ressenti thermique
/// - Indicateur de mise à jour et statut de cache local
class MainWeatherCard extends StatelessWidget {
  const MainWeatherCard({
    super.key,
    required this.weather,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final Weather weather;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final isFromCache =
        DateTime.now().difference(weather.fetchedAt).inMinutes >= 1;

    final description = weather.description.isEmpty
        ? ''
        : '${weather.description[0].toUpperCase()}'
              '${weather.description.substring(1)}';

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date du jour
          Text(
            FrDate.full(weather.fetchedAt),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),

          // Ville + bouton favoris
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
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onToggleFavorite != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: isFavorite
                      ? 'Retirer des favoris'
                      : 'Ajouter aux favoris',
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite
                        ? Colors.redAccent
                        : Colors.white.withValues(alpha: 0.85),
                    size: 24,
                  ),
                  onPressed: onToggleFavorite,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Icône météo (réseau avec fallback emoji)
          _WeatherIconDisplay(iconCode: weather.iconCode, size: 120),
          const SizedBox(height: 4),

          // Température actuelle
          Text(
            '${weather.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 88,
              fontWeight: FontWeight.w200,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Min / Max et Ressenti
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              Text(
                'Min ${weather.tempMin.round()}°  •  Max ${weather.tempMax.round()}°',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'Ressenti ${weather.feelsLike.round()}°',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Statut de fraîcheur / cache
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFromCache ? Icons.cloud_done_outlined : Icons.sync_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isFromCache
                      ? 'Données en cache • Mis à jour à ${FrDate.time(weather.fetchedAt)}'
                      : 'Mis à jour à ${FrDate.time(weather.fetchedAt)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherIconDisplay extends StatelessWidget {
  const _WeatherIconDisplay({required this.iconCode, required this.size});

  final String iconCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (iconCode.isEmpty) {
      return WeatherGlyph(iconCode: iconCode, size: size);
    }

    final url = 'https://openweathermap.org/img/wn/$iconCode@4x.png';

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          WeatherGlyph(iconCode: iconCode, size: size),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return WeatherGlyph(iconCode: iconCode, size: size);
      },
    );
  }
}
