import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';

class GetMyReviewsUseCase {
  final ReviewRepository repository;

  GetMyReviewsUseCase({required this.repository});

  Future<Either<Failure, PagedReviews>> call({
    int page = 0,
    int size = 20,
  }) {
    return repository.getMyReviews(
      page: page,
      size: size,
    );
  }
}
