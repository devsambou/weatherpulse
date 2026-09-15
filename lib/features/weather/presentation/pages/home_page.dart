import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/theme/weather_palette.dart';
import '../../../../core/utils/fr_date.dart';
import '../../domain/entities/weather.dart';
import '../viewmodels/weather_view_model.dart';
import '../widgets/city_search_field.dart';
import '../widgets/contextual_header.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/favorites_bar.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/weather_state_views.dart';

/// Écran principal de WeatherPulse (F05 + F06).
///
/// Responsabilités :
///  - piloter [weatherViewModelProvider] (recherche ville, position GPS) ;
///  - peindre un dégradé plein écran animé qui reflète la condition météo et le thème ;
///  - afficher le header contextuel (salutation selon l'heure, ville, paramètres) ;
///  - router entre les états chargement / erreur / vide / données avec transitions douces ;
///  - adapter la mise en page : mobile portrait (colonne défilante) et
///    tablette / paysage large (deux colonnes).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherViewModelProvider);
    final viewModel = ref.read(weatherViewModelProvider.notifier);

    final weather = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };

    // Dérivation de la condition et de la palette météo selon le thème actif
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final condition = WeatherCondition.fromWeather(weather);
    final palette = WeatherPalette.get(condition, isDark: isDark);
    final gradient = palette.backgroundGradient;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: gradient.first,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradient,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header contextuel avec salutation dynamique & accès paramètres
                ContextualHeader(weather: weather),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CitySearchField(
                    onSubmitted: viewModel.loadByCity,
                    // TODO(Géolocalisation): une fois `locationServiceProvider`
                    // implémenté, ce bouton chargera la position réelle (F04).
                    onUseLocation: viewModel.loadFromDeviceLocation,
                  ),
                ),
                const SizedBox(height: 10),
                FavoritesBar(
                  selectedCity: weather?.cityName,
                  onCitySelected: viewModel.loadByCity,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: switch (state) {
                      AsyncData(:final value) =>
                        value == null
                            ? const WeatherEmptyView(key: ValueKey('empty'))
                            : _WeatherContent(
                                key: ValueKey(
                                  'content_${value.cityName}_${value.fetchedAt.millisecondsSinceEpoch}',
                                ),
                                weather: value,
                                palette: palette,
                                onRefresh: viewModel.refresh,
                              ),
                      AsyncError(:final error) => WeatherErrorView(
                        key: const ValueKey('error'),
                        message: error is Failure
                            ? error.message
                            : 'Une erreur inattendue est survenue.',
                        onRetry: viewModel.refresh,
                      ),
                      _ => const WeatherLoadingView(key: ValueKey('loading')),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Corps « données prêtes », responsive (F06) avec intégration de la palette météo.
class _WeatherContent extends StatelessWidget {
  const _WeatherContent({
    super.key,
    required this.weather,
    required this.palette,
    required this.onRefresh,
  });

  final Weather weather;
  final WeatherPalette palette;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final hero = CurrentWeatherView(weather: weather);
    final details = WeatherDetailsGrid(weather: weather);
    final isFromCache =
        DateTime.now().difference(weather.fetchedAt).inMinutes >= 1;
    final updated = Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFromCache ? Icons.cloud_done_outlined : Icons.sync_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                isFromCache
                    ? 'Données en cache • Mis à jour à ${FrDate.time(weather.fetchedAt)}'
                    : 'Mis à jour à ${FrDate.time(weather.fetchedAt)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: palette.primary,
      backgroundColor: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Seuil tablette / paysage large -> deux colonnes.
          final isWide = constraints.maxWidth >= 600;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 24, 12, 24),
                    children: [const SizedBox(height: 8), hero],
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 32, 24, 24),
                    children: [details, updated],
                  ),
                ),
              ],
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [hero, const SizedBox(height: 36), details, updated],
          );
        },
      ),
    );
  }
}