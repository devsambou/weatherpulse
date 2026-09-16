import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/core/errors/failures.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_day.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_hour.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/get_forecast_by_city.dart';
import 'package:weatherpulse_g16/features/weather/domain/usecases/get_forecast_hours_by_city.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/forecast_view_model.dart';
import 'package:weatherpulse_g16/features/weather/presentation/viewmodels/weather_providers.dart';

class FakeGetForecastByCity extends Fake implements GetForecastByCity {
  Either<Failure, List<ForecastDay>>? result;
  String? lastCity;
  int callCount = 0;

  @override
  Future<Either<Failure, List<ForecastDay>>> call(String city) async {
    callCount++;
    lastCity = city;
    return result!;
  }
}

class FakeGetForecastHoursByCity extends Fake
    implements GetForecastHoursByCity {
  Either<Failure, List<ForecastHour>>? result;
  String? lastCity;
  int callCount = 0;

  @override
  Future<Either<Failure, List<ForecastHour>>> call(String city) async {
    callCount++;
    lastCity = city;
    return result!;
  }
}

void main() {
  late FakeGetForecastByCity fakeGetForecastByCity;
  late FakeGetForecastHoursByCity fakeGetForecastHoursByCity;
  late ProviderContainer container;

  final tDays = [
    ForecastDay(
      date: DateTime(2024, 7, 19),
      tempMin: 20.0,
      tempMax: 30.0,
      description: 'ensoleillé',
      iconCode: '01d',
    ),
  ];

  final tHours = [
    ForecastHour(
      dateTime: DateTime(2024, 7, 18, 14, 0),
      temperature: 28.0,
      feelsLike: 29.0,
      description: 'ensoleillé',
      iconCode: '01d',
    ),
  ];

  setUp(() {
    fakeGetForecastByCity = FakeGetForecastByCity();
    fakeGetForecastHoursByCity = FakeGetForecastHoursByCity();

    container = ProviderContainer(
      overrides: [
        getForecastByCityProvider.overrideWithValue(fakeGetForecastByCity),
        getForecastHoursByCityProvider.overrideWithValue(
          fakeGetForecastHoursByCity,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ForecastViewModel', () {
    test('initial state est null', () async {
      final state = await container.read(forecastViewModelProvider.future);
      expect(state, isNull);
    });

    test('loadForCity avec chaîne vide ne fait rien', () async {
      await container
          .read(forecastViewModelProvider.notifier)
          .loadForCity('  ');
      final state = container.read(forecastViewModelProvider);
      expect(state.value, isNull);
      expect(fakeGetForecastByCity.callCount, 0);
    });

    test('loadForCity avec succès charge days et hours', () async {
      fakeGetForecastByCity.result = Right(tDays);
      fakeGetForecastHoursByCity.result = Right(tHours);

      await container
          .read(forecastViewModelProvider.notifier)
          .loadForCity('Dakar');

      final state = container.read(forecastViewModelProvider);
      expect(state.value?.days, equals(tDays));
      expect(state.value?.hours, equals(tHours));

      // Rappel avec la même ville quand déjà chargée ne redéclenche pas
      await container
          .read(forecastViewModelProvider.notifier)
          .loadForCity('dakar');
      expect(fakeGetForecastByCity.callCount, 1);
    });

    test(
      'loadForCity quand hours échoue mais days réussit conserve les jours',
      () async {
        fakeGetForecastByCity.result = Right(tDays);
        fakeGetForecastHoursByCity.result = const Left(ServerFailure('Erreur'));

        await container
            .read(forecastViewModelProvider.notifier)
            .loadForCity('Paris');

        final state = container.read(forecastViewModelProvider);
        expect(state.value?.days, equals(tDays));
        expect(state.value?.hours, isEmpty);
      },
    );

    test('loadForCity quand days échoue met en AsyncError', () async {
      fakeGetForecastByCity.result = const Left(CityNotFoundFailure('404'));
      fakeGetForecastHoursByCity.result = Right(tHours);

      await container
          .read(forecastViewModelProvider.notifier)
          .loadForCity('Inconnue');

      final state = container.read(forecastViewModelProvider);
      expect(state.hasError, isTrue);
    });

    test('refresh recharge la ville courante', () async {
      fakeGetForecastByCity.result = Right(tDays);
      fakeGetForecastHoursByCity.result = Right(tHours);

      await container
          .read(forecastViewModelProvider.notifier)
          .loadForCity('Dakar');
      await container.read(forecastViewModelProvider.notifier).refresh();

      expect(fakeGetForecastByCity.callCount, 2);
    });
  });
}
