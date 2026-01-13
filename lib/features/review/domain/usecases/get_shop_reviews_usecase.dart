import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';

class GetShopReviewsUseCase {
  final ReviewRepository repository;

  GetShopReviewsUseCase({required this.repository});

  Future<Either<Failure, PagedReviews>> call({
    required String shopId,
    int page = 0,
    int size = 20,
  }) {
    return repository.getShopReviews(
      shopId: shopId,
      page: page,
      size: size,
    );
  }
}
