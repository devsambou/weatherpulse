import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/favorites_view_model.dart';

/// Barre horizontale défilante des villes favorites (F07).
class FavoritesBar extends ConsumerWidget {
  const FavoritesBar({
    super.key,
    required this.onCitySelected,
    this.selectedCity,
  });

  final ValueChanged<String> onCitySelected;
  final String? selectedCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesViewModelProvider);

    return favoritesAsync.when(
      data: (favorites) {
        if (favorites.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final city = favorites[index];
              final isSelected =
                  selectedCity != null &&
                  selectedCity!.toLowerCase() == city.cityName.toLowerCase();

              return InkWell(
                borderRadius: BorderRadius.circular(19),
                onTap: () => onCitySelected(city.cityName),
                child: Container(
                  padding: const EdgeInsets.only(left: 12, right: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.80)
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amberAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        city.cityName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(favoritesViewModelProvider.notifier)
                              .removeCity(city.cityName);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
