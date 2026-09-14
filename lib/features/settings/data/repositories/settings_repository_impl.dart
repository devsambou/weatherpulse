import 'package:flutter/material.dart';

import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Implémentation du repository de paramètres s'appuyant sur [SettingsLocalDataSource].
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  ThemeMode getThemeMode() => localDataSource.getThemeMode();

  @override
  Future<void> saveThemeMode(ThemeMode mode) =>
      localDataSource.saveThemeMode(mode);
}
