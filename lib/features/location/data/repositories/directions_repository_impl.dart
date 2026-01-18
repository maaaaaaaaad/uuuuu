import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
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
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return const Left(NetworkFailure('네트워크 연결을 확인해주세요'));
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        return Left(ServerFailure(data['error'].toString()));
      }

      return Left(ServerFailure(e.message ?? '서버 오류가 발생했습니다'));
    }
  }
}
