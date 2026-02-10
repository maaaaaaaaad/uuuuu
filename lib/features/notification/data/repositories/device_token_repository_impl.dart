import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/notification/data/datasources/device_token_remote_datasource.dart';
import 'package:jellomark/features/notification/domain/repositories/device_token_repository.dart';

class DeviceTokenRepositoryImpl implements DeviceTokenRepository {
  final DeviceTokenRemoteDataSource _remoteDataSource;

  DeviceTokenRepositoryImpl({required DeviceTokenRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, void>> registerToken(
      String token, String platform) async {
    try {
      await _remoteDataSource.registerToken(token, platform);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? '토큰 등록에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterToken(String token) async {
    try {
      await _remoteDataSource.unregisterToken(token);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? '토큰 해제에 실패했습니다'));
    }
  }
}
