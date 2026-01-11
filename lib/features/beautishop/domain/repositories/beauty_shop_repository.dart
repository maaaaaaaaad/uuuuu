import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';

abstract class BeautyShopRepository {
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

  Future<Either<Failure, List<ShopReview>>> getShopReviews(String shopId);
}
