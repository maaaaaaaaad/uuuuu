import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/core/network/api_error_handler.dart';
import 'package:jellomark/features/usage_history/data/datasources/usage_history_remote_datasource.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';
import 'package:jellomark/features/usage_history/domain/repositories/usage_history_repository.dart';

class UsageHistoryRepositoryImpl implements UsageHistoryRepository {
  final UsageHistoryRemoteDataSource remoteDataSource;

  UsageHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UsageHistory>>> getMyUsageHistory() async {
    try {
      final models = await remoteDataSource.getMyUsageHistory();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiErrorHandler.fromDioException(e, fallback: '이용 내역을 불러올 수 없습니다'),
      );
    }
  }
}
