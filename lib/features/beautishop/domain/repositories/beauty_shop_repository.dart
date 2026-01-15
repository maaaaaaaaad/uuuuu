import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_shop_reviews.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';

abstract class BeautyShopRepository {
  Future<Either<Failure, PagedBeautyShops>> getBeautyShops({
    required int page,
    required int size,
    String? keyword,
    String? sortBy,
    String? sortOrder,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? minRating,
  });

  Future<Either<Failure, BeautyShop>> getBeautyShopById(String shopId);

  Future<Either<Failure, List<BeautyShop>>> getNearbyShops({
    required double latitude,
    required double longitude,
    double? radiusKm,
  });

  Future<Either<Failure, List<BeautyShop>>> getRecommendedShops();

  Future<Either<Failure, List<BeautyShop>>> getDiscountShops();

  Future<Either<Failure, List<BeautyShop>>> getNewShops();

  Future<Either<Failure, ShopDetail>> getShopDetail(String shopId);

  Future<Either<Failure, List<ServiceMenu>>> getShopServices(String shopId);

  Future<Either<Failure, PagedShopReviews>> getShopReviews(
    String shopId, {
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  });
}
