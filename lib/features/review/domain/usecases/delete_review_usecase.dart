import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';

class DeleteReviewUseCase {
  final ReviewRepository repository;

  DeleteReviewUseCase({required this.repository});

  Future<Either<Failure, void>> call({
    required String shopId,
    required String reviewId,
  }) {
    return repository.deleteReview(
      shopId: shopId,
      reviewId: reviewId,
    );
  }
}
