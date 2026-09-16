import 'package:flutter/material.dart';

import '../../../../core/utils/fr_date.dart';
import '../../../../core/utils/weather_visuals.dart';
import '../../domain/entities/weather.dart';

/// Header contextuel (CDC C) affichant :
/// - une salutation selon l'heure de la journée (Bonjour, Bon après-midi, Bonsoir) ;
/// - le nom de la ville sélectionnée ;
/// - l'heure de dernière mise à jour ;
/// - l'icône et la condition météo.
class ContextualHeader extends StatelessWidget {
  const ContextualHeader({super.key, required this.weather, this.now});

  final Weather? weather;

  /// Paramètre optionnel permettant d'injecter une date/heure fixe pour les tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final currentTime = now ?? DateTime.now();
    final greeting = FrDate.greeting(currentTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barre supérieure : Titre centré
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'WEATHERPULSE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bloc contextuel animé
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey('${weather?.cityName}_${weather?.fetchedAt}'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  // Icône contextuelle selon la météo
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      weather != null
                          ? WeatherVisuals.icon(weather!.iconCode)
                          : Icons.waving_hand_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Salutation et détails ville / mise à jour
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting !',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (weather != null)
                          Text(
                            '${weather!.cityName} • Mis à jour à ${FrDate.time(weather!.fetchedAt)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            'Recherchez une ville pour afficher la météo',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
