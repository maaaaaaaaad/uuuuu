import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';
import 'package:jellomark/features/review/domain/usecases/update_review_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late UpdateReviewUseCase useCase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    useCase = UpdateReviewUseCase(repository: mockRepository);
  });

  final tReview = Review(
    id: 'review-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    rating: 4,
    content: 'Updated!',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 16),
  );

  group('UpdateReviewUseCase', () {
    const tShopId = 'shop-1';
    const tReviewId = 'review-1';
    const tRating = 4;
    const tContent = 'Updated!';

    test('should return Review when repository call is successful', () async {
      when(() => mockRepository.updateReview(
            shopId: tShopId,
            reviewId: tReviewId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenAnswer((_) async => Right(tReview));

      final result = await useCase(
        shopId: tShopId,
        reviewId: tReviewId,
        rating: tRating,
        content: tContent,
      );

      expect(result, Right(tReview));
      verify(() => mockRepository.updateReview(
            shopId: tShopId,
            reviewId: tReviewId,
            rating: tRating,
            content: tContent,
            images: null,
          )).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.updateReview(
            shopId: tShopId,
            reviewId: tReviewId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase(
        shopId: tShopId,
        reviewId: tReviewId,
        rating: tRating,
        content: tContent,
      );

      expect(result, isA<Left<Failure, Review>>());
    });
  });
}
