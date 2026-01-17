import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';

abstract class LocationRepository {
  Future<Either<Failure, UserLocation>> getCurrentLocation();
  Future<Either<Failure, bool>> requestLocationPermission();
  Future<bool> isLocationPermissionGranted();
}
