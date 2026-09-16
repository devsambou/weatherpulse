import 'package:flutter/material.dart';

/// Couleur d'accent réutilisée pour les boutons posés sur le dégradé.
const Color _accent = Color(0xFF2E6FD6);

/// Vue de chargement, posée sur le dégradé de fond.
class WeatherLoadingView extends StatelessWidget {
  const WeatherLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement de la météo…',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/// Vue d'erreur : message clair + action « Réessayer » (F03).
class WeatherErrorView extends StatelessWidget {
  const WeatherErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => onRetry(),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _accent,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// État initial : aucune ville chargée.
class WeatherEmptyView extends StatelessWidget {
  const WeatherEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_queue_rounded, size: 72, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'Recherchez une ville pour afficher sa météo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
