import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/favorite/domain/entities/favorite_shop.dart';
import 'package:jellomark/features/favorite/domain/repositories/favorite_repository.dart';

class AddFavoriteUseCase {
  final FavoriteRepository _repository;

  AddFavoriteUseCase(this._repository);

  Future<Either<Failure, FavoriteShop>> call(String shopId) {
    return _repository.addFavorite(shopId);
  }
}
