import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/weather_visuals.dart';
import '../../domain/entities/weather.dart';
import '../viewmodels/favorites_view_model.dart';
import '../viewmodels/forecast_view_model.dart';
import '../viewmodels/weather_view_model.dart';
import '../widgets/favorites_bar.dart';
import '../widgets/forecast_hourly_section.dart';
import '../widgets/main_weather_card.dart';
import '../widgets/weather_detail_card.dart';
import '../widgets/weather_search_field.dart';
import '../widgets/weather_state_views.dart';

/// Écran principal de WeatherPulse avec composants météo premium (F01 à F07).
///
/// Intègre :
/// - Barre de recherche pilule avec état de chargement et gestion d'erreur
/// - Carte météo principale glassmorphism
/// - Barre de favoris interactive
/// - Section de prévisions avec toggle Par heure / Quotidien
/// - Grille responsive des détails météo enrichis
/// - Animations soignées (AnimatedSwitcher, transitions douces)
/// - Dégradé dynamique adapté à la condition météo et au cycle jour/nuit
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écoute les changements de météo pour synchroniser les prévisions
    ref.listen<AsyncValue<Weather?>>(weatherViewModelProvider, (prev, next) {
      if (next case AsyncData(:final value?) when value != prev?.value) {
        ref
            .read(forecastViewModelProvider.notifier)
            .loadForCity(value.cityName);
      }
    });

    final state = ref.watch(weatherViewModelProvider);
    final viewModel = ref.read(weatherViewModelProvider.notifier);

    final weather = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final gradient = WeatherVisuals.backgroundGradient(weather?.iconCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final errorMessage = switch (state) {
      AsyncError(:final error) =>
        error is Failure
            ? error.message
            : 'Une erreur inattendue est survenue.',
      _ => null,
    };

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
                const SizedBox(height: 10),
                const Text(
                  'WEATHERPULSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 14),

                // Barre de recherche élégante en pilule (Fonctionnalité 4)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: WeatherSearchField(
                    isLoading: state is AsyncLoading,
                    errorMessage: errorMessage,
                    onSubmitted: (city) {
                      viewModel.loadByCity(city);
                      ref
                          .read(forecastViewModelProvider.notifier)
                          .loadForCity(city);
                    },
                    onUseLocation: viewModel.loadFromDeviceLocation,
                  ),
                ),
                const SizedBox(height: 10),

                // Barre des villes favorites
                FavoritesBar(
                  selectedCity: weather?.cityName,
                  onCitySelected: (city) {
                    viewModel.loadByCity(city);
                    ref
                        .read(forecastViewModelProvider.notifier)
                        .loadForCity(city);
                  },
                ),

                // Contenu principal avec AnimatedSwitcher (Fonctionnalité 5)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: switch (state) {
                      AsyncData(:final value) =>
                        value == null
                            ? const WeatherEmptyView(key: ValueKey('empty'))
                            : _WeatherContent(
                                key: ValueKey(value.cityName),
                                weather: value,
                                onRefresh: () async {
                                  await viewModel.refresh();
                                  await ref
                                      .read(forecastViewModelProvider.notifier)
                                      .refresh();
                                },
                              ),
                      AsyncError(:final error) => WeatherErrorView(
                        key: const ValueKey('error'),
                        message: error is Failure
                            ? error.message
                            : 'Une erreur inattendue est survenue.',
                        onRetry: () async {
                          await viewModel.refresh();
                          await ref
                              .read(forecastViewModelProvider.notifier)
                              .refresh();
                        },
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

/// Corps responsive affichant la météo et ses prévisions
class _WeatherContent extends ConsumerWidget {
  const _WeatherContent({
    super.key,
    required this.weather,
    required this.onRefresh,
  });

  final Weather weather;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesViewModelProvider).value ?? [];
    final isFavorite = favorites.any(
      (c) => c.cityName.toLowerCase() == weather.cityName.trim().toLowerCase(),
    );

    final forecastState = ref.watch(forecastViewModelProvider);
    final forecastData = forecastState.value;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF2E6FD6),
      backgroundColor: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          final mainCard = MainWeatherCard(
            weather: weather,
            isFavorite: isFavorite,
            onToggleFavorite: () {
              ref
                  .read(favoritesViewModelProvider.notifier)
                  .toggleFavorite(weather.cityName);
            },
          );

          final forecastSection = ForecastSectionView(
            hours: forecastData?.hours ?? const [],
            days: forecastData?.days ?? const [],
          );

          final detailsGrid = WeatherDetailsEnrichedGrid(weather: weather);

          if (isWide) {
            // Disposition tablette / grand écran (2 colonnes)
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 12, 24),
                    children: [
                      mainCard,
                      const SizedBox(height: 20),
                      forecastSection,
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 16, 24, 24),
                    children: [
                      const Text(
                        'Conditions météo détaillées',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      detailsGrid,
                    ],
                  ),
                ),
              ],
            );
          }

          // Disposition mobile portrait
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            children: [
              mainCard,
              const SizedBox(height: 22),
              forecastSection,
              const SizedBox(height: 22),
              const Text(
                'Conditions météo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              detailsGrid,
            ],
          );
        },
      ),
    );
  }
}
