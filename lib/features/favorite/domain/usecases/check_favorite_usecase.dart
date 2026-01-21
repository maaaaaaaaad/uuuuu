import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/favorite/domain/repositories/favorite_repository.dart';

class CheckFavoriteUseCase {
  final FavoriteRepository _repository;

  CheckFavoriteUseCase(this._repository);

  Future<Either<Failure, bool>> call(String shopId) {
    return _repository.checkFavorite(shopId);
  }
}
