import 'package:flutter_test/flutter_test.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/favorite_city.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_day.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/forecast_hour.dart';
import 'package:weatherpulse_g16/features/weather/domain/entities/weather.dart';

void main() {
  final tDate = DateTime(2024, 7, 18, 12, 0);

  group('Weather Entity', () {
    test('props et égalité fonctionnent correctement', () {
      final w1 = Weather(
        cityName: 'Dakar',
        temperature: 30.0,
        feelsLike: 32.0,
        description: 'ensoleillé',
        iconCode: '01d',
        humidity: 60,
        windSpeed: 4.0,
        fetchedAt: tDate,
        sunrise: tDate,
        sunset: tDate,
        windDegree: 180,
        cloudiness: 10,
        pressure: 1012,
        visibility: 10000,
        rainVolume: 0.0,
        tempMin: 28.0,
        tempMax: 33.0,
      );

      final w2 = Weather(
        cityName: 'Dakar',
        temperature: 30.0,
        feelsLike: 32.0,
        description: 'ensoleillé',
        iconCode: '01d',
        humidity: 60,
        windSpeed: 4.0,
        fetchedAt: tDate,
        sunrise: tDate,
        sunset: tDate,
        windDegree: 180,
        cloudiness: 10,
        pressure: 1012,
        visibility: 10000,
        rainVolume: 0.0,
        tempMin: 28.0,
        tempMax: 33.0,
      );

      expect(w1, equals(w2));
      expect(w1.props.length, 17);
    });
  });

  group('ForecastDay Entity', () {
    test('props et égalité fonctionnent correctement', () {
      final fd1 = ForecastDay(
        date: tDate,
        tempMin: 18.0,
        tempMax: 26.0,
        description: 'pluie',
        iconCode: '10d',
        fetchedAt: tDate,
      );

      final fd2 = ForecastDay(
        date: tDate,
        tempMin: 18.0,
        tempMax: 26.0,
        description: 'pluie',
        iconCode: '10d',
        fetchedAt: tDate,
      );

      expect(fd1, equals(fd2));
      expect(fd1.props.length, 6);
    });
  });

  group('ForecastHour Entity', () {
    test('props et égalité fonctionnent correctement', () {
      final fh1 = ForecastHour(
        dateTime: tDate,
        temperature: 22.0,
        feelsLike: 22.5,
        description: 'nuageux',
        iconCode: '04d',
        pop: 0.1,
        rainVolume: 0.2,
        windSpeed: 5.0,
        humidity: 70,
      );

      final fh2 = ForecastHour(
        dateTime: tDate,
        temperature: 22.0,
        feelsLike: 22.5,
        description: 'nuageux',
        iconCode: '04d',
        pop: 0.1,
        rainVolume: 0.2,
        windSpeed: 5.0,
        humidity: 70,
      );

      expect(fh1, equals(fh2));
      expect(fh1.props.length, 9);
    });
  });

  group('FavoriteCity Entity', () {
    test('props et égalité fonctionnent correctement', () {
      final fc1 = FavoriteCity(cityName: 'Paris', addedAt: tDate);
      final fc2 = FavoriteCity(cityName: 'Paris', addedAt: tDate);

      expect(fc1, equals(fc2));
      expect(fc1.props.length, 2);
    });
  });
}
