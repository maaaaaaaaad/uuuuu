import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';

class UpdateReviewUseCase {
  final ReviewRepository repository;

  UpdateReviewUseCase({required this.repository});

  Future<Either<Failure, Review>> call({
    required String shopId,
    required String reviewId,
    int? rating,
    String? content,
    List<String>? images,
  }) {
    return repository.updateReview(
      shopId: shopId,
      reviewId: reviewId,
      rating: rating,
      content: content,
      images: images,
    );
  }
}
