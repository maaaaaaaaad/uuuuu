import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_shop_reviews.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';

void main() {
  group('PagedShopReviews', () {
    test('should create PagedShopReviews with items', () {
      final reviews = [
        ShopReview(
          id: '1',
          authorName: '김민지',
          rating: 4.5,
          content: '좋아요!',
          createdAt: DateTime(2024, 1, 15),
        ),
        ShopReview(
          id: '2',
          authorName: '박서연',
          rating: 5.0,
          content: '최고예요!',
          createdAt: DateTime(2024, 1, 14),
        ),
      ];

      final pagedReviews = PagedShopReviews(
        items: reviews,
        hasNext: true,
        totalElements: 10,
      );

      expect(pagedReviews.items.length, 2);
      expect(pagedReviews.hasNext, isTrue);
      expect(pagedReviews.totalElements, 10);
    });

    test('should create empty PagedShopReviews', () {
      const pagedReviews = PagedShopReviews(
        items: [],
        hasNext: false,
        totalElements: 0,
      );

      expect(pagedReviews.items, isEmpty);
      expect(pagedReviews.hasNext, isFalse);
      expect(pagedReviews.totalElements, 0);
    });

    test('should support equality comparison', () {
      final reviews = [
        ShopReview(
          id: '1',
          authorName: '김민지',
          rating: 4.5,
          content: '좋아요!',
          createdAt: DateTime(2024, 1, 15),
        ),
      ];

      final paged1 = PagedShopReviews(
        items: reviews,
        hasNext: false,
        totalElements: 1,
      );

      final paged2 = PagedShopReviews(
        items: reviews,
        hasNext: false,
        totalElements: 1,
      );

      expect(paged1, equals(paged2));
    });
  });
}
