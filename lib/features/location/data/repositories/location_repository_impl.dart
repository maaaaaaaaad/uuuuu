import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/data/datasources/location_datasource.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;

  LocationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserLocation>> getCurrentLocation() async {
    try {
      final isServiceEnabled = await dataSource.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return const Left(LocationServiceDisabledFailure());
      }

      final isGranted = await dataSource.isPermissionGranted();
      if (!isGranted) {
        final granted = await dataSource.requestPermission();
        if (!granted) {
          return const Left(LocationPermissionDeniedFailure());
        }
      }

      final position = await dataSource.getCurrentPosition();
      return Right(UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    } catch (e) {
      return Left(LocationFailure('위치를 가져오는데 실패했습니다: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestLocationPermission() async {
    try {
      final granted = await dataSource.requestPermission();
      return Right(granted);
    } catch (e) {
      return Left(LocationFailure('권한 요청에 실패했습니다: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLocationPermissionGranted() async {
    return await dataSource.isPermissionGranted();
  }
}
