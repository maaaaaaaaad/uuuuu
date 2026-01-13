import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/review/data/models/review_model.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';

void main() {
  group('ReviewModel', () {
    const tReviewModel = ReviewModel(
      id: '1',
      shopId: 'shop-1',
      memberId: 'member-1',
      rating: 5,
      content: 'Great service!',
      images: ['image1.jpg', 'image2.jpg'],
      createdAt: '2024-01-15T10:30:00Z',
      updatedAt: '2024-01-15T10:30:00Z',
    );

    test('should be a subclass of Review entity', () {
      expect(tReviewModel.toEntity(), isA<Review>());
    });

    test('should convert to Review entity correctly', () {
      final result = tReviewModel.toEntity();

      expect(result.id, '1');
      expect(result.shopId, 'shop-1');
      expect(result.memberId, 'member-1');
      expect(result.rating, 5);
      expect(result.content, 'Great service!');
      expect(result.images, ['image1.jpg', 'image2.jpg']);
      expect(result.createdAt, DateTime.utc(2024, 1, 15, 10, 30, 0));
      expect(result.updatedAt, DateTime.utc(2024, 1, 15, 10, 30, 0));
    });

    test('should create ReviewModel from JSON', () {
      final json = {
        'id': '1',
        'shopId': 'shop-1',
        'memberId': 'member-1',
        'rating': 5,
        'content': 'Great service!',
        'images': ['image1.jpg', 'image2.jpg'],
        'createdAt': '2024-01-15T10:30:00Z',
        'updatedAt': '2024-01-15T10:30:00Z',
      };

      final result = ReviewModel.fromJson(json);

      expect(result, tReviewModel);
    });

    test('should handle null images in JSON', () {
      final json = {
        'id': '1',
        'shopId': 'shop-1',
        'memberId': 'member-1',
        'rating': 5,
        'content': 'Great service!',
        'images': null,
        'createdAt': '2024-01-15T10:30:00Z',
        'updatedAt': '2024-01-15T10:30:00Z',
      };

      final result = ReviewModel.fromJson(json);

      expect(result.images, isEmpty);
    });

    test('should convert to JSON correctly', () {
      final result = tReviewModel.toJson();

      expect(result['id'], '1');
      expect(result['shopId'], 'shop-1');
      expect(result['memberId'], 'member-1');
      expect(result['rating'], 5);
      expect(result['content'], 'Great service!');
      expect(result['images'], ['image1.jpg', 'image2.jpg']);
    });
  });
}
