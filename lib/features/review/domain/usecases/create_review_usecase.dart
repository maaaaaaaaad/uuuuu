import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase({required this.repository});

  Future<Either<Failure, Review>> call({
    required String shopId,
    required int rating,
    required String content,
    List<String>? images,
  }) {
    return repository.createReview(
      shopId: shopId,
      rating: rating,
      content: content,
      images: images,
    );
  }
}
