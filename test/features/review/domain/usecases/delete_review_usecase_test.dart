import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';
import 'package:jellomark/features/review/domain/usecases/delete_review_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late DeleteReviewUseCase useCase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    useCase = DeleteReviewUseCase(repository: mockRepository);
  });

  group('DeleteReviewUseCase', () {
    const tShopId = 'shop-1';
    const tReviewId = 'review-1';

    test('should return void when repository call is successful', () async {
      when(() => mockRepository.deleteReview(
            shopId: tShopId,
            reviewId: tReviewId,
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(
        shopId: tShopId,
        reviewId: tReviewId,
      );

      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRepository.deleteReview(
            shopId: tShopId,
            reviewId: tReviewId,
          )).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.deleteReview(
            shopId: tShopId,
            reviewId: tReviewId,
          )).thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase(
        shopId: tShopId,
        reviewId: tReviewId,
      );

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
