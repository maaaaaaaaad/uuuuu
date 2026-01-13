import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';

void main() {
  group('Review', () {
    test('should create Review with required fields', () {
      final review = Review(
        id: '1',
        shopId: 'shop-1',
        memberId: 'member-1',
        rating: 5,
        content: 'Great service!',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      expect(review.id, '1');
      expect(review.shopId, 'shop-1');
      expect(review.memberId, 'member-1');
      expect(review.rating, 5);
      expect(review.content, 'Great service!');
      expect(review.images, isEmpty);
    });

    test('should create Review with images', () {
      final review = Review(
        id: '1',
        shopId: 'shop-1',
        memberId: 'member-1',
        rating: 4,
        content: 'Nice!',
        images: ['image1.jpg', 'image2.jpg'],
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      expect(review.images, ['image1.jpg', 'image2.jpg']);
      expect(review.hasImages, true);
    });

    test('hasImages returns false when images is empty', () {
      final review = Review(
        id: '1',
        shopId: 'shop-1',
        memberId: 'member-1',
        rating: 5,
        content: 'Great!',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      expect(review.hasImages, false);
    });

    test('two Reviews with same props should be equal', () {
      final createdAt = DateTime(2024, 1, 15);
      final updatedAt = DateTime(2024, 1, 15);

      final review1 = Review(
        id: '1',
        shopId: 'shop-1',
        memberId: 'member-1',
        rating: 5,
        content: 'Great!',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final review2 = Review(
        id: '1',
        shopId: 'shop-1',
        memberId: 'member-1',
        rating: 5,
        content: 'Great!',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(review1, review2);
    });

    group('formattedDate', () {
      test('returns "방금 전" for less than 1 hour ago', () {
        final review = Review(
          id: '1',
          shopId: 'shop-1',
          memberId: 'member-1',
          rating: 5,
          content: 'Great!',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          updatedAt: DateTime.now(),
        );

        expect(review.formattedDate, '방금 전');
      });

      test('returns hours ago for less than 24 hours', () {
        final review = Review(
          id: '1',
          shopId: 'shop-1',
          memberId: 'member-1',
          rating: 5,
          content: 'Great!',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          updatedAt: DateTime.now(),
        );

        expect(review.formattedDate, '5시간 전');
      });

      test('returns days ago for less than 7 days', () {
        final review = Review(
          id: '1',
          shopId: 'shop-1',
          memberId: 'member-1',
          rating: 5,
          content: 'Great!',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now(),
        );

        expect(review.formattedDate, '3일 전');
      });

      test('returns formatted date for 7 days or more', () {
        final review = Review(
          id: '1',
          shopId: 'shop-1',
          memberId: 'member-1',
          rating: 5,
          content: 'Great!',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        expect(review.formattedDate, '2024.01.15');
      });
    });
  });
}
