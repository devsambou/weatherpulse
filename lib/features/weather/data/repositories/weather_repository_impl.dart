import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
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
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
      double lat, double lon) async {
    try {
      final cacheKey = '$lat,$lon';
      final cached = await localDataSource.getCachedWeather(cacheKey);
      if (cached != null) return Right(cached);

      final result = await remoteDataSource.getWeatherByCoordinates(lat, lon);
      await localDataSource.cacheWeather(cacheKey, result);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
