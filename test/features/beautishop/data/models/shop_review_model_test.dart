import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/data/models/shop_review_model.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';

void main() {
  group('ShopReviewModel', () {
    final testJsonWithAllFields = {
      'id': 'review-1',
      'authorName': '김민지',
      'rating': 4.5,
      'content': '너무 좋아요! 다음에 또 올게요.',
      'createdAt': '2024-01-15T10:30:00Z',
      'images': [
        'https://example.com/img1.jpg',
        'https://example.com/img2.jpg',
      ],
      'authorProfileImage': 'https://example.com/profile.jpg',
      'serviceName': '젤네일 기본',
    };

    test('extends ShopReview', () {
      final model = ShopReviewModel.fromJson(testJsonWithAllFields);
      expect(model, isA<ShopReview>());
    });

    test('fromJson parses all fields correctly', () {
      final model = ShopReviewModel.fromJson(testJsonWithAllFields);
      expect(model.id, 'review-1');
      expect(model.authorName, '김민지');
      expect(model.rating, 4.5);
      expect(model.content, '너무 좋아요! 다음에 또 올게요.');
      expect(model.images.length, 2);
      expect(model.authorProfileImage, 'https://example.com/profile.jpg');
      expect(model.serviceName, '젤네일 기본');
    });

    test('fromJson handles rating only (no content)', () {
      final json = {
        'id': 'review-2',
        'authorName': '박서연',
        'rating': 5.0,
        'content': null,
        'createdAt': '2024-01-15T10:30:00Z',
      };

      final model = ShopReviewModel.fromJson(json);
      expect(model.rating, 5.0);
      expect(model.content, isNull);
      expect(model.hasRating, isTrue);
      expect(model.hasContent, isFalse);
    });

    test('fromJson handles content only (no rating)', () {
      final json = {
        'id': 'review-3',
        'authorName': '이수진',
        'rating': null,
        'content': '좋은 서비스였습니다!',
        'createdAt': '2024-01-15T10:30:00Z',
      };

      final model = ShopReviewModel.fromJson(json);
      expect(model.rating, isNull);
      expect(model.content, '좋은 서비스였습니다!');
      expect(model.hasRating, isFalse);
      expect(model.hasContent, isTrue);
    });

    test('fromJson handles missing authorName with default', () {
      final json = {
        'id': 'review-4',
        'rating': 4.0,
        'content': '좋아요',
        'createdAt': '2024-01-15T10:30:00Z',
      };

      final model = ShopReviewModel.fromJson(json);
      expect(model.authorName, '익명');
    });

    test('fromJson handles missing images', () {
      final json = {
        'id': 'review-5',
        'authorName': '최유나',
        'rating': 4.0,
        'content': '좋아요',
        'createdAt': '2024-01-15T10:30:00Z',
      };

      final model = ShopReviewModel.fromJson(json);
      expect(model.images, isEmpty);
    });

    test('fromJson parses createdAt correctly', () {
      final model = ShopReviewModel.fromJson(testJsonWithAllFields);
      expect(model.createdAt, DateTime.utc(2024, 1, 15, 10, 30, 0));
    });
  });
}
