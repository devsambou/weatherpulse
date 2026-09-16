import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_shell.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/fr_date.dart';
import '../../domain/entities/favorite_city.dart';
import '../viewmodels/favorites_view_model.dart';
import '../viewmodels/forecast_view_model.dart';
import '../viewmodels/weather_view_model.dart';
import '../widgets/glass_container.dart';

/// Page dédiée à la gestion et visualisation des villes favorites (F07).
///
/// Fonctionnalités :
/// - Liste les villes favorites enregistrées dans Hive
/// - Ajoute une nouvelle ville après validation d'existence
/// - Supprime une ville des favoris
/// - Sélectionne une ville favorite :
///   * vérifie si elle est déjà chargée (évite requêtes inutiles)
///   * charge la météo et les prévisions si nécessaire
///   * bascule vers l'écran d'accueil
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  final _addController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _submitCity() async {
    final city = _addController.text.trim();
    if (city.isEmpty) return;

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    await ref.read(favoritesViewModelProvider.notifier).addCity(city);

    if (mounted) {
      _addController.clear();
      setState(() => _isSubmitting = false);
    }
  }

  void _selectFavoriteCity(String cityName) {
    final cleanCity = cityName.trim();
    if (cleanCity.isEmpty) return;

    // Vérifie si des données valides existent déjà pour éviter les requêtes inutiles
    final currentWeather = ref.read(weatherViewModelProvider).value;
    final isAlreadyLoaded =
        currentWeather != null &&
        currentWeather.cityName.trim().toLowerCase() == cleanCity.toLowerCase();

    if (!isAlreadyLoaded) {
      ref.read(weatherViewModelProvider.notifier).loadByCity(cleanCity);
      ref.read(forecastViewModelProvider.notifier).loadForCity(cleanCity);
    }

    // Bascule vers la page d'accueil (index 0)
    ref.read(navigationIndexProvider.notifier).setIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoritesViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Villes Favorites'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            // Champ d'ajout rapide de ville favorite
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_location_alt_outlined,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _addController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submitCity(),
                        decoration: const InputDecoration(
                          hintText: 'Ajouter une ville aux favoris...',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_isSubmitting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_rounded,
                          color: Colors.white,
                        ),
                        tooltip: 'Ajouter',
                        onPressed: _submitCity,
                      ),
                  ],
                ),
              ),
            ),

            // Contenu principal : liste ou état vide
            Expanded(
              child: favoritesState.when(
                data: (favorites) {
                  if (favorites.isEmpty) {
                    return _FavoritesEmptyState(
                      onAddQuickCity: (city) {
                        _addController.text = city;
                        _submitCity();
                      },
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: favorites.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final city = favorites[index];
                      return _FavoriteCityTile(
                        city: city,
                        onTap: () => _selectFavoriteCity(city.cityName),
                        onDelete: () {
                          ref
                              .read(favoritesViewModelProvider.notifier)
                              .removeCity(city.cityName);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.white70,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Une erreur est survenue lors du chargement des favoris.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: GlassStyles.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tuile représentant une ville favorite individuelle.
class _FavoriteCityTile extends StatelessWidget {
  const _FavoriteCityTile({
    required this.city,
    required this.onTap,
    required this.onDelete,
  });

  final FavoriteCity city;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.amberAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.cityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Ajoutée le ${FrDate.full(city.addedAt)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.white.withValues(alpha: 0.70),
                size: 22,
              ),
              tooltip: 'Supprimer des favoris',
              onPressed: onDelete,
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Vue affichée lorsque la liste des favoris est vide.
class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState({required this.onAddQuickCity});

  final ValueChanged<String> onAddQuickCity;

  @override
  Widget build(BuildContext context) {
    final suggested = ['Paris', 'Tokyo', 'Dakar', 'New York'];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_outline_rounded,
                color: Colors.white70,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune ville favorite',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enregistrez vos villes préférées pour accéder à leur météo en un clic.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Suggestions rapides :',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggested.map((city) {
                return ActionChip(
                  label: Text(city),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () => onAddQuickCity(city),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
