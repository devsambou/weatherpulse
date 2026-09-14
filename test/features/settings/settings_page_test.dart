import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/settings/domain/repositories/settings_repository.dart';
import 'package:weatherpulse_g16/features/settings/presentation/pages/settings_page.dart';
import 'package:weatherpulse_g16/features/settings/presentation/viewmodels/settings_providers.dart';

class FakeSettingsRepository implements SettingsRepository {
  ThemeMode mode = ThemeMode.system;

  @override
  ThemeMode getThemeMode() => mode;

  @override
  Future<void> saveThemeMode(ThemeMode newMode) async {
    mode = newMode;
  }
}

void main() {
  late FakeSettingsRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeSettingsRepository();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(fakeRepo)],
      child: const MaterialApp(home: SettingsPage()),
    );
  }

  group('SettingsPage Widget', () {
    testWidgets('affiche les options de thème Système, Clair et Sombre', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Système'), findsOneWidget);
      expect(find.text('Clair'), findsOneWidget);
      expect(find.text('Sombre'), findsOneWidget);
      expect(find.text('PALETTE DYNAMIQUE'), findsOneWidget);
    });

    testWidgets('permet de changer de thème vers Clair puis Sombre', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      // Initialement en Système
      expect(fakeRepo.getThemeMode(), ThemeMode.system);

      // Cliquer sur Clair
      await tester.tap(find.text('Clair'));
      await tester.pumpAndSettle();

      expect(fakeRepo.getThemeMode(), ThemeMode.light);

      // Cliquer sur Sombre
      await tester.tap(find.text('Sombre'));
      await tester.pumpAndSettle();

      expect(fakeRepo.getThemeMode(), ThemeMode.dark);
    });
  });
}
