import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';
import 'package:jellomark/features/review/domain/usecases/create_review_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late CreateReviewUseCase useCase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    useCase = CreateReviewUseCase(repository: mockRepository);
  });

  final tReview = Review(
    id: '1',
    shopId: 'shop-1',
    memberId: 'member-1',
    rating: 5,
    content: 'Great!',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  );

  group('CreateReviewUseCase', () {
    const tShopId = 'shop-1';
    const tRating = 5;
    const tContent = 'Great!';
    final tImages = ['image1.jpg'];

    test('should return Review when repository call is successful', () async {
      when(() => mockRepository.createReview(
            shopId: tShopId,
            rating: tRating,
            content: tContent,
            images: tImages,
          )).thenAnswer((_) async => Right(tReview));

      final result = await useCase(
        shopId: tShopId,
        rating: tRating,
        content: tContent,
        images: tImages,
      );

      expect(result, Right(tReview));
      verify(() => mockRepository.createReview(
            shopId: tShopId,
            rating: tRating,
            content: tContent,
            images: tImages,
          )).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.createReview(
            shopId: tShopId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase(
        shopId: tShopId,
        rating: tRating,
        content: tContent,
      );

      expect(result, isA<Left<Failure, Review>>());
    });
  });
}
