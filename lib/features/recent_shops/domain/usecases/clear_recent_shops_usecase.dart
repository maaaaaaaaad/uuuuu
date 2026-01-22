import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/recent_shops/domain/repositories/recent_shops_repository.dart';

class ClearRecentShopsUseCase {
  final RecentShopsRepository _repository;

  ClearRecentShopsUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.clearRecentShops();
  }
}
