import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';
import 'package:jellomark/features/review/domain/usecases/get_my_reviews_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late GetMyReviewsUseCase useCase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    useCase = GetMyReviewsUseCase(repository: mockRepository);
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

  final tPagedReviews = PagedReviews(
    items: [tReview],
    hasNext: true,
    totalElements: 10,
  );

  group('GetMyReviewsUseCase', () {
    const tPage = 0;
    const tSize = 20;

    test('should return PagedReviews from repository', () async {
      when(() => mockRepository.getMyReviews(
            page: tPage,
            size: tSize,
          )).thenAnswer((_) async => Right(tPagedReviews));

      final result = await useCase(
        page: tPage,
        size: tSize,
      );

      expect(result, Right(tPagedReviews));
      verify(() => mockRepository.getMyReviews(
            page: tPage,
            size: tSize,
          )).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getMyReviews(
            page: tPage,
            size: tSize,
          )).thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase(
        page: tPage,
        size: tSize,
      );

      expect(result, isA<Left<Failure, PagedReviews>>());
    });

    test('should use default page and size when not provided', () async {
      when(() => mockRepository.getMyReviews(
            page: 0,
            size: 20,
          )).thenAnswer((_) async => Right(tPagedReviews));

      final result = await useCase();

      expect(result, Right(tPagedReviews));
      verify(() => mockRepository.getMyReviews(
            page: 0,
            size: 20,
          )).called(1);
    });
  });
}
