import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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

      final permissionStatus = await dataSource.checkPermissionStatus();
      if (permissionStatus == LocationPermissionStatus.deniedForever) {
        return const Left(LocationPermissionDeniedForeverFailure());
      }

      if (permissionStatus != LocationPermissionStatus.granted) {
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
      debugPrint('[LocationRepositoryImpl] requestLocationPermission called');
      // deniedForever 상태라도 requestPermission을 호출해야 iOS 시스템 다이얼로그가 표시될 수 있음
      debugPrint('[LocationRepositoryImpl] calling dataSource.requestPermission()');
      final granted = await dataSource.requestPermission();
      debugPrint('[LocationRepositoryImpl] granted: $granted');
      return Right(granted);
    } catch (e) {
      debugPrint('[LocationRepositoryImpl] Exception: $e');
      return Left(LocationFailure('권한 요청에 실패했습니다: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLocationPermissionGranted() async {
    return await dataSource.isPermissionGranted();
  }

  @override
  Future<LocationPermissionResult> checkPermissionStatus() async {
    final status = await dataSource.checkPermissionStatus();
    switch (status) {
      case LocationPermissionStatus.granted:
        return LocationPermissionResult.granted;
      case LocationPermissionStatus.deniedForever:
        return LocationPermissionResult.deniedForever;
      case LocationPermissionStatus.denied:
        return LocationPermissionResult.denied;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    return await dataSource.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() async {
    return await dataSource.openLocationSettings();
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await dataSource.isLocationServiceEnabled();
  }
}
