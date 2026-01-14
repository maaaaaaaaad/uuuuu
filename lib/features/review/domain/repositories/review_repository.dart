import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, PagedReviews>> getShopReviews({
    required String shopId,
    required int page,
    required int size,
  });

  Future<Either<Failure, Review>> createReview({
    required String shopId,
    int? rating,
    String? content,
    List<String>? images,
  });

  Future<Either<Failure, Review>> updateReview({
    required String shopId,
    required String reviewId,
    int? rating,
    String? content,
    List<String>? images,
  });

  Future<Either<Failure, void>> deleteReview({
    required String shopId,
    required String reviewId,
  });
}
