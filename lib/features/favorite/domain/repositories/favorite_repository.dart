import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/favorite/domain/entities/favorite_shop.dart';
import 'package:jellomark/features/favorite/domain/entities/paged_favorites.dart';

abstract class FavoriteRepository {
  Future<Either<Failure, FavoriteShop>> addFavorite(String shopId);
  Future<Either<Failure, void>> removeFavorite(String shopId);
  Future<Either<Failure, PagedFavorites>> getFavorites({
    int page = 0,
    int size = 20,
  });
  Future<Either<Failure, bool>> checkFavorite(String shopId);
}
