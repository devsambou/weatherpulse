import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:weatherpulse_g16/core/constants/api_constants.dart';
import 'package:weatherpulse_g16/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:weatherpulse_g16/features/settings/data/repositories/settings_repository_impl.dart';

// Mock manuel d'une Box Hive pour les tests
class MockSettingsBox extends Mock implements Box<String> {
  final Map<dynamic, String> _storage = {};

  @override
  String? get(dynamic key, {String? defaultValue}) {
    return _storage[key] ?? defaultValue;
  }

  @override
  Future<void> put(dynamic key, String value) async {
    _storage[key] = value;
  }
}

void main() {
  late MockSettingsBox mockBox;
  late SettingsLocalDataSourceImpl dataSource;
  late SettingsRepositoryImpl repository;

  setUp(() {
    mockBox = MockSettingsBox();
    dataSource = SettingsLocalDataSourceImpl(mockBox);
    repository = SettingsRepositoryImpl(localDataSource: dataSource);
  });

  group('SettingsLocalDataSourceImpl', () {
    test(
      'retourne ThemeMode.system par défaut quand aucune clé n\'est enregistrée',
      () {
        final mode = dataSource.getThemeMode();
        expect(mode, ThemeMode.system);
      },
    );

    test('persiste et lit correctement ThemeMode.light', () async {
      await dataSource.saveThemeMode(ThemeMode.light);
      expect(mockBox.get(SettingsConstants.themeModeKey), 'light');
      expect(dataSource.getThemeMode(), ThemeMode.light);
    });

    test('persiste et lit correctement ThemeMode.dark', () async {
      await dataSource.saveThemeMode(ThemeMode.dark);
      expect(mockBox.get(SettingsConstants.themeModeKey), 'dark');
      expect(dataSource.getThemeMode(), ThemeMode.dark);
    });

    test('persiste et lit correctement ThemeMode.system', () async {
      await dataSource.saveThemeMode(ThemeMode.system);
      expect(mockBox.get(SettingsConstants.themeModeKey), 'system');
      expect(dataSource.getThemeMode(), ThemeMode.system);
    });
  });

  group('SettingsRepositoryImpl', () {
    test('délègue getThemeMode au datasource', () {
      expect(repository.getThemeMode(), ThemeMode.system);
    });

    test('délègue saveThemeMode au datasource', () async {
      await repository.saveThemeMode(ThemeMode.dark);
      expect(repository.getThemeMode(), ThemeMode.dark);
    });
  });
}
