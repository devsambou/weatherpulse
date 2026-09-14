import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/forecast_day.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_datasource.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Convertit une exception technique en Failure métier (F03)
  Failure _mapException(Object e) {
    if (e is CityNotFoundException) {
      return CityNotFoundFailure(e.message);
    } else if (e is QuotaExceededException) {
      return QuotaExceededFailure(e.message);
    } else if (e is ServerException) {
      return ServerErrorFailure(e.message, statusCode: e.statusCode);
    } else if (e is NetworkException) {
      return NetworkFailure(e.message);
    }
    return ServerFailure(e.toString());
  }

  @override
  Future<Either<Failure, Weather>> getWeatherByCity(String city) async {
    try {
      // 1. Tente le cache d'abord (feature bonus)
      final cached = await localDataSource.getCachedWeather(city);
      if (cached != null) return Right(cached);

      // 2. Sinon appel réseau
      final result = await remoteDataSource.getWeatherByCity(city);
      await localDataSource.cacheWeather(city, result);
      return Right(result);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final cacheKey = '$lat,$lon';
      final cached = await localDataSource.getCachedWeather(cacheKey);
      if (cached != null) return Right(cached);

      final result = await remoteDataSource.getWeatherByCoordinates(lat, lon);
      await localDataSource.cacheWeather(cacheKey, result);
      return Right(result);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<ForecastDay>>> getForecastByCity(
    String city,
  ) async {
    try {
      // 1. Tente le cache d'abord (feature bonus)
      final cached = await localDataSource.getCachedForecast(city);
      if (cached != null) return Right(cached);

      // 2. Sinon appel réseau
      final result = await remoteDataSource.getForecastByCity(city);
      await localDataSource.cacheForecast(city, result);
      return Right(result);
    } catch (e) {
      return Left(_mapException(e));
    }
  }
}
