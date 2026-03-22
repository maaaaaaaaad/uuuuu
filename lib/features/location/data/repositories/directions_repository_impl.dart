import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/core/network/api_error_handler.dart';
import 'package:jellomark/features/location/data/datasources/directions_remote_data_source.dart';
import 'package:jellomark/features/location/domain/entities/route.dart';
import 'package:jellomark/features/location/domain/repositories/directions_repository.dart';

class DirectionsRepositoryImpl implements DirectionsRepository {
  final DirectionsRemoteDataSource remoteDataSource;

  DirectionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Route>> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {
      final response = await remoteDataSource.getDirections(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      if (!response.isSuccess) {
        return Left(ServerFailure(response.message));
      }

      final route = response.toRoute();
      if (route == null) {
        return const Left(ServerFailure('경로를 찾을 수 없습니다'));
      }

      return Right(route);
    } on DioException catch (e) {
      return Left(
        ApiErrorHandler.fromDioException(e, fallback: '경로를 불러올 수 없습니다'),
      );
    }
  }
}
