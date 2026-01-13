import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:jellomark/features/treatment/domain/repositories/treatment_repository.dart';

class TreatmentRepositoryImpl implements TreatmentRepository {
  final TreatmentRemoteDataSource _remoteDataSource;

  TreatmentRepositoryImpl({
    required TreatmentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<ServiceMenu>>> getShopTreatments(
    String shopId,
  ) async {
    try {
      final treatments = await _remoteDataSource.getShopTreatments(shopId);
      return Right(treatments);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ServiceMenu>> getTreatmentById(
    String treatmentId,
  ) async {
    try {
      final treatment = await _remoteDataSource.getTreatmentById(treatmentId);
      return Right(treatment);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      return (e.response?.data as Map)['error']?.toString() ?? '알 수 없는 오류';
    }
    return e.message ?? '알 수 없는 오류';
  }
}
