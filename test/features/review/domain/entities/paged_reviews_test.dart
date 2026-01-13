import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';

void main() {
  group('PagedReviews', () {
    test('should create PagedReviews with required fields', () {
      final reviews = [
        Review(
          id: '1',
          shopId: 'shop-1',
          memberId: 'member-1',
          rating: 5,
          content: 'Great!',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        ),
      ];

      final pagedReviews = PagedReviews(
        items: reviews,
        hasNext: true,
        totalElements: 10,
      );

      expect(pagedReviews.items, reviews);
      expect(pagedReviews.hasNext, true);
      expect(pagedReviews.totalElements, 10);
    });

    test('should create empty PagedReviews', () {
      const pagedReviews = PagedReviews(
        items: [],
        hasNext: false,
        totalElements: 0,
      );

      expect(pagedReviews.items, isEmpty);
      expect(pagedReviews.hasNext, false);
      expect(pagedReviews.totalElements, 0);
    });

    test('two PagedReviews with same props should be equal', () {
      final reviews = [
        Review(
          id: '1',
          shopId: 'shop-1',
          memberId: 'member-1',
          rating: 5,
          content: 'Great!',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        ),
      ];

      final pagedReviews1 = PagedReviews(
        items: reviews,
        hasNext: true,
        totalElements: 10,
      );

      final pagedReviews2 = PagedReviews(
        items: reviews,
        hasNext: true,
        totalElements: 10,
      );

      expect(pagedReviews1, pagedReviews2);
    });
  });
}
