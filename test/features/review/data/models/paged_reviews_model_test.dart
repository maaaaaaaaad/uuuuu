import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/review/data/models/paged_reviews_model.dart';
import 'package:jellomark/features/review/data/models/review_model.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';

void main() {
  group('PagedReviewsModel', () {
    const tReviewModel = ReviewModel(
      id: '1',
      shopId: 'shop-1',
      memberId: 'member-1',
      rating: 5,
      content: 'Great!',
      images: [],
      createdAt: '2024-01-15T10:30:00Z',
      updatedAt: '2024-01-15T10:30:00Z',
    );

    final tPagedReviewsModel = PagedReviewsModel(
      items: const [tReviewModel],
      hasNext: true,
      totalElements: 10,
    );

    test('should be a subclass of PagedReviews entity', () {
      expect(tPagedReviewsModel.toEntity(), isA<PagedReviews>());
    });

    test('should convert to PagedReviews entity correctly', () {
      final result = tPagedReviewsModel.toEntity();

      expect(result.items.length, 1);
      expect(result.items.first.id, '1');
      expect(result.hasNext, true);
      expect(result.totalElements, 10);
    });

    test('should create PagedReviewsModel from JSON', () {
      final json = {
        'items': [
          {
            'id': '1',
            'shopId': 'shop-1',
            'memberId': 'member-1',
            'rating': 5,
            'content': 'Great!',
            'images': <dynamic>[],
            'createdAt': '2024-01-15T10:30:00Z',
            'updatedAt': '2024-01-15T10:30:00Z',
          }
        ],
        'hasNext': true,
        'totalElements': 10,
      };

      final result = PagedReviewsModel.fromJson(json);

      expect(result.items.length, 1);
      expect(result.items.first.id, '1');
      expect(result.hasNext, true);
      expect(result.totalElements, 10);
    });

    test('should handle empty items in JSON', () {
      final json = {
        'items': <dynamic>[],
        'hasNext': false,
        'totalElements': 0,
      };

      final result = PagedReviewsModel.fromJson(json);

      expect(result.items, isEmpty);
      expect(result.hasNext, false);
      expect(result.totalElements, 0);
    });
  });
}
