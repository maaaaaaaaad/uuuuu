import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/repositories/recent_shops_repository.dart';

class AddRecentShopUseCase {
  final RecentShopsRepository _repository;

  AddRecentShopUseCase(this._repository);

  Future<Either<Failure, void>> call(RecentShop shop) {
    return _repository.addRecentShop(shop);
  }
}
