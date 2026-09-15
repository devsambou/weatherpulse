import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/api_constants.dart';

/// Contrat de stockage local des paramètres de l'application via Hive.
abstract class SettingsLocalDataSource {
  ThemeMode getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}

/// Implémentation Hive du datasource des paramètres.
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Box<String> settingsBox;

  SettingsLocalDataSourceImpl(this.settingsBox);

  @override
  ThemeMode getThemeMode() {
    final raw = settingsBox.get(SettingsConstants.themeModeKey);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await settingsBox.put(SettingsConstants.themeModeKey, value);
  }
}
