import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/forecast_day.dart';
import '../../domain/entities/forecast_hour.dart';
import 'weather_providers.dart';

typedef ForecastData = ({List<ForecastDay> days, List<ForecastHour> hours});

final forecastViewModelProvider =
    AsyncNotifierProvider<ForecastViewModel, ForecastData?>(
      ForecastViewModel.new,
    );

class ForecastViewModel extends AsyncNotifier<ForecastData?> {
  String? _currentCity;

  @override
  Future<ForecastData?> build() async => null;

  Future<void> loadForCity(String city) async {
    final query = city.trim();
    if (query.isEmpty) return;
    if (_currentCity?.toLowerCase() == query.toLowerCase() &&
        state.hasValue &&
        state.value != null) {
      return;
    }

    _currentCity = query;
    state = const AsyncValue.loading();

    final daysResult = await ref.read(getForecastByCityProvider).call(query);
    final hoursResult = await ref
        .read(getForecastHoursByCityProvider)
        .call(query);

    daysResult.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (days) {
        hoursResult.fold(
          (failure) {
            // Si les heures échouent, on présente quand même les jours
            state = AsyncValue.data((days: days, hours: const []));
          },
          (hours) {
            state = AsyncValue.data((days: days, hours: hours));
          },
        );
      },
    );
  }

  Future<void> refresh() async {
    final city = _currentCity;
    if (city != null) {
      _currentCity = null;
      await loadForCity(city);
    }
  }
}
