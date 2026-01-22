import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/repositories/recent_shops_repository.dart';

class GetRecentShopsUseCase {
  final RecentShopsRepository _repository;

  GetRecentShopsUseCase(this._repository);

  Future<Either<Failure, List<RecentShop>>> call() {
    return _repository.getRecentShops();
  }
}
