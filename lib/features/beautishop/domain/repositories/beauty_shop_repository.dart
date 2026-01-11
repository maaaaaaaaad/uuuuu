import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';

abstract class BeautyShopRepository {
  Future<Either<Failure, List<BeautyShop>>> getNearbyShops({
    required double latitude,
    required double longitude,
    double? radiusKm,
  });

  Future<Either<Failure, List<BeautyShop>>> getRecommendedShops();

  Future<Either<Failure, List<BeautyShop>>> getDiscountShops();

  Future<Either<Failure, List<BeautyShop>>> getNewShops();
}
