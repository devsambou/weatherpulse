import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_providers.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_view_model.dart';

import '../../../helpers/fake_weather_repository.dart';

void main() {
  group('WeatherViewModel', () {
    test('état initial : aucune ville chargée', () async {
      final container = ProviderContainer(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(FakeWeatherRepository()),
        ],
      );
      addTearDown(container.dispose);

      final value = await container.read(weatherViewModelProvider.future);

      expect(value, isNull);
    });

    test('loadByCity : renvoie la météo en cas de succès', () async {
      final container = ProviderContainer(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(FakeWeatherRepository()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(weatherViewModelProvider.future);

      await container
          .read(weatherViewModelProvider.notifier)
          .loadByCity('Dakar');

      final state = container.read(weatherViewModelProvider);
      expect(state.hasError, isFalse);
      expect(state.value?.cityName, 'Dakar');
      expect(state.value?.temperature, 27);
    });

    test('loadByCity : ignore une saisie vide', () async {
      final container = ProviderContainer(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(FakeWeatherRepository()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(weatherViewModelProvider.future);

      await container.read(weatherViewModelProvider.notifier).loadByCity('   ');

      final state = container.read(weatherViewModelProvider);
      expect(state.value, isNull);
      expect(state.isLoading, isFalse);
    });

    test(
      'loadByCity : expose la Failure du repository en cas d\'échec',
      () async {
        final container = ProviderContainer(
          overrides: [
            weatherRepositoryProvider.overrideWithValue(
              FakeWeatherRepository(shouldFail: true),
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(weatherViewModelProvider.future);

        await container
            .read(weatherViewModelProvider.notifier)
            .loadByCity('Atlantide');

        final state = container.read(weatherViewModelProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<NetworkFailure>());
      },
    );

    test('refresh : relance la dernière recherche par ville', () async {
      final container = ProviderContainer(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(FakeWeatherRepository()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(weatherViewModelProvider.future);
      final notifier = container.read(weatherViewModelProvider.notifier);

      await notifier.loadByCity('Dakar');
      await notifier.refresh();

      final state = container.read(weatherViewModelProvider);
      expect(state.value?.cityName, 'Dakar');
    });
  });
}
