import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/favorite/domain/entities/paged_favorites.dart';
import 'package:jellomark/features/favorite/domain/repositories/favorite_repository.dart';

class GetFavoritesParams {
  final int page;
  final int size;

  const GetFavoritesParams({this.page = 0, this.size = 20});
}

class GetFavoritesUseCase {
  final FavoriteRepository _repository;

  GetFavoritesUseCase(this._repository);

  Future<Either<Failure, PagedFavorites>> call(GetFavoritesParams params) {
    return _repository.getFavorites(page: params.page, size: params.size);
  }
}
