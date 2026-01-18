import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/domain/entities/route.dart';

abstract class DirectionsRepository {
  Future<Either<Failure, Route>> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  });
}
