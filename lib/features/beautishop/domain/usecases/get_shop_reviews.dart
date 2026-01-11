import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';

class GetShopReviews {
  final BeautyShopRepository repository;

  GetShopReviews({required this.repository});

  Future<Either<Failure, List<ShopReview>>> call({required String shopId}) {
    return repository.getShopReviews(shopId);
  }
}
