import 'package:flutter/material.dart';

/// Contrat du repository de gestion des paramètres de l'application.
abstract class SettingsRepository {
  ThemeMode getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}
