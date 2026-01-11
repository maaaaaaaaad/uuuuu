import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';

void main() {
  group('ShopReview', () {
    test('should create ShopReview with required fields', () {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '네일 너무 예쁘게 해주셨어요!',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(review.id, '1');
      expect(review.authorName, '김민지');
      expect(review.rating, 4.5);
      expect(review.content, '네일 너무 예쁘게 해주셨어요!');
      expect(review.createdAt, DateTime(2024, 1, 15));
    });

    test('should have optional images list', () {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '네일 너무 예쁘게 해주셨어요!',
        createdAt: DateTime(2024, 1, 15),
        images: ['review1.jpg', 'review2.jpg'],
      );

      expect(review.images.length, 2);
      expect(review.images[0], 'review1.jpg');
    });

    test('should have optional author profile image', () {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '네일 너무 예쁘게 해주셨어요!',
        createdAt: DateTime(2024, 1, 15),
        authorProfileImage: 'profile.jpg',
      );

      expect(review.authorProfileImage, 'profile.jpg');
    });

    test('should have optional service name', () {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '네일 너무 예쁘게 해주셨어요!',
        createdAt: DateTime(2024, 1, 15),
        serviceName: '젤네일 기본',
      );

      expect(review.serviceName, '젤네일 기본');
    });

    test('should format date as relative time for recent reviews', () {
      final now = DateTime.now();
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: now.subtract(const Duration(hours: 2)),
      );

      expect(review.formattedDate, '2시간 전');
    });

    test('should format date as days ago', () {
      final now = DateTime.now();
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: now.subtract(const Duration(days: 3)),
      );

      expect(review.formattedDate, '3일 전');
    });

    test('should format date as month.day for older reviews', () {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: DateTime(2024, 3, 15),
      );

      expect(review.formattedDate, '2024.03.15');
    });

    test('should check if review has images', () {
      final reviewWithImages = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: DateTime(2024, 1, 15),
        images: ['image1.jpg'],
      );

      final reviewWithoutImages = ShopReview(
        id: '2',
        authorName: '박서연',
        rating: 4.0,
        content: '괜찮아요',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(reviewWithImages.hasImages, isTrue);
      expect(reviewWithoutImages.hasImages, isFalse);
    });

    test('should support equality comparison', () {
      final review1 = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: DateTime(2024, 1, 15),
      );

      final review2 = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(review1, equals(review2));
    });
  });
}
