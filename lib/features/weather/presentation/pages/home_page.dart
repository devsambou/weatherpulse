import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/fr_date.dart';
import '../../../../core/utils/weather_visuals.dart';
import '../../domain/entities/weather.dart';
import '../viewmodels/weather_view_model.dart';
import '../widgets/city_search_field.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/weather_state_views.dart';

/// Écran principal de WeatherPulse (F05 + F06).
///
/// Responsabilités :
///  - piloter [weatherViewModelProvider] (recherche ville, position GPS) ;
///  - peindre un dégradé plein écran qui reflète la condition météo ;
///  - router entre les états chargement / erreur / vide / données ;
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
    final gradient = WeatherVisuals.backgroundGradient(weather?.iconCode);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CitySearchField(
                    onSubmitted: viewModel.loadByCity,
                    // TODO(Géolocalisation): une fois `locationServiceProvider`
                    // implémenté, ce bouton chargera la position réelle (F04).
                    onUseLocation: viewModel.loadFromDeviceLocation,
                  ),
                ),
                Expanded(
                  child: switch (state) {
                    AsyncData(:final value) =>
                      value == null
                          ? const WeatherEmptyView()
                          : _WeatherContent(
                              weather: value,
                              onRefresh: viewModel.refresh,
                            ),
                    AsyncError(:final error) => WeatherErrorView(
                      message: error is Failure
                          ? error.message
                          : 'Une erreur inattendue est survenue.',
                      onRetry: viewModel.refresh,
                    ),
                    _ => const WeatherLoadingView(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Corps « données prêtes », responsive (F06).
class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.weather, required this.onRefresh});

  final Weather weather;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final hero = CurrentWeatherView(weather: weather);
    final details = WeatherDetailsGrid(weather: weather);
    final updated = Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        'Mis à jour à ${FrDate.time(weather.fetchedAt)}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 12,
        ),
      ),
    );

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF2E6FD6),
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
