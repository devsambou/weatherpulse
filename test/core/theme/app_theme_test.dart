import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme retourne les configurations Material 3 attendues', () {
      final theme = AppTheme.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.appBarTheme.centerTitle, isTrue);
      expect(theme.cardTheme.elevation, 0);
    });

    test('dark theme retourne les configurations Material 3 attendues', () {
      final theme = AppTheme.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0F1722));
    });
  });

  group('GlassStyles', () {
    testWidgets('retourne les styles en mode sombre et clair', (tester) async {
      late BuildContext lightCtx;
      late BuildContext darkCtx;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (ctx) {
              lightCtx = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(GlassStyles.accent, const Color(0xFF2E6FD6));
      expect(GlassStyles.textPrimary(lightCtx), Colors.white);
      expect(GlassStyles.glassBackground(lightCtx), isNotNull);
      expect(GlassStyles.glassBorder(lightCtx), isNotNull);
      expect(GlassStyles.textSecondary(lightCtx), isNotNull);
      expect(GlassStyles.searchFieldBackground(lightCtx), isNotNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (ctx) {
              darkCtx = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(GlassStyles.glassBackground(darkCtx), isNotNull);
      expect(GlassStyles.glassBorder(darkCtx), isNotNull);
      expect(GlassStyles.textSecondary(darkCtx), isNotNull);
      expect(GlassStyles.searchFieldBackground(darkCtx), isNotNull);
    });
  });
}
