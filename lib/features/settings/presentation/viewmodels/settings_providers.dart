import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/settings_repository.dart';

/// Point d'injection du repository de paramètres.
/// Doit être surchargé au démarrage dans le `ProviderScope` racine (`main.dart`).
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError(
    'settingsRepositoryProvider doit être surchargé dans le ProviderScope racine '
    '(main.dart) avec une implémentation de SettingsRepository.',
  );
});

/// Provider exposant le [ThemeMode] actif de l'application et permettant sa modification.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.watch(settingsRepositoryProvider).getThemeMode();
  }

  /// Change le mode de thème et persiste le choix dans Hive.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(settingsRepositoryProvider).saveThemeMode(mode);
  }
}
