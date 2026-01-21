import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/favorite/domain/repositories/favorite_repository.dart';

class RemoveFavoriteUseCase {
  final FavoriteRepository _repository;

  RemoveFavoriteUseCase(this._repository);

  Future<Either<Failure, void>> call(String shopId) {
    return _repository.removeFavorite(shopId);
  }
}
