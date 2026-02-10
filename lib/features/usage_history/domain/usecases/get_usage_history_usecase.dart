import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';
import 'package:jellomark/features/usage_history/domain/repositories/usage_history_repository.dart';

class GetUsageHistoryUseCase {
  final UsageHistoryRepository repository;

  GetUsageHistoryUseCase({required this.repository});

  Future<Either<Failure, List<UsageHistory>>> call() {
    return repository.getMyUsageHistory();
  }
}
