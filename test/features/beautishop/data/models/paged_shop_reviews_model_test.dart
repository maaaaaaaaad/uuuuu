import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/data/models/paged_shop_reviews_model.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_shop_reviews.dart';

void main() {
  group('PagedShopReviewsModel', () {
    final testJson = {
      'items': [
        {
          'id': 'review-1',
          'authorName': '김민지',
          'rating': 4.5,
          'content': '너무 좋아요!',
          'createdAt': '2024-01-15T10:30:00Z',
        },
        {
          'id': 'review-2',
          'authorName': '박서연',
          'rating': 5.0,
          'content': '최고입니다!',
          'createdAt': '2024-01-14T09:00:00Z',
        },
      ],
      'hasNext': true,
      'totalElements': 25,
    };

    test('extends PagedShopReviews', () {
      final model = PagedShopReviewsModel.fromJson(testJson);
      expect(model, isA<PagedShopReviews>());
    });

    test('fromJson parses items correctly', () {
      final model = PagedShopReviewsModel.fromJson(testJson);
      expect(model.items.length, 2);
      expect(model.items[0].authorName, '김민지');
      expect(model.items[1].authorName, '박서연');
    });

    test('fromJson parses hasNext correctly', () {
      final model = PagedShopReviewsModel.fromJson(testJson);
      expect(model.hasNext, isTrue);
    });

    test('fromJson parses totalElements correctly', () {
      final model = PagedShopReviewsModel.fromJson(testJson);
      expect(model.totalElements, 25);
    });

    test('fromJson handles empty items', () {
      final emptyJson = {
        'items': [],
        'hasNext': false,
        'totalElements': 0,
      };

      final model = PagedShopReviewsModel.fromJson(emptyJson);
      expect(model.items, isEmpty);
      expect(model.hasNext, isFalse);
      expect(model.totalElements, 0);
    });

    test('fromJson handles missing fields with defaults', () {
      final minimalJson = <String, dynamic>{};

      final model = PagedShopReviewsModel.fromJson(minimalJson);
      expect(model.items, isEmpty);
      expect(model.hasNext, isFalse);
      expect(model.totalElements, 0);
    });
  });
}
