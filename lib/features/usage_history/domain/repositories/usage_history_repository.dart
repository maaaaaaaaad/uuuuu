import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';

abstract class UsageHistoryRepository {
  Future<Either<Failure, List<UsageHistory>>> getMyUsageHistory();
}
