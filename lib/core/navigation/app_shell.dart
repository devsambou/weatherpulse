import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/weather/presentation/pages/favorites_page.dart';
import '../../features/weather/presentation/pages/home_page.dart';

/// Notifier gérant l'index de navigation actif (0: Accueil, 1: Favoris, 2: Paramètres).
class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(
  NavigationIndexNotifier.new,
);

/// Coquille applicative principale avec barre de navigation unique et IndexedStack.
///
/// L'utilisation d'[IndexedStack] préserve l'arbre des widgets et l'état
/// des trois écrans sans rechargement intempestif ni perte de données.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [HomePage(), FavoritesPage(), SettingsPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).setIndex(index);
        },
        backgroundColor: isDark
            ? const Color(0xFF141B26)
            : Colors.white.withValues(alpha: 0.95),
        indicatorColor: isDark
            ? const Color(0xFF2E6FD6).withValues(alpha: 0.35)
            : const Color(0xFF2E6FD6).withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline_rounded),
            selectedIcon: Icon(Icons.star_rounded),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
