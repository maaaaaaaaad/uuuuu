import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/data/models/paged_beauty_shops_model.dart';
import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';

void main() {
  group('PagedBeautyShopsModel', () {
    final testShopJson = {
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'name': '뷰티살롱 강남',
      'regNum': '123-45-67890',
      'phoneNumber': '02-1234-5678',
      'address': '서울시 강남구 테헤란로 123',
      'latitude': 37.5065,
      'longitude': 127.0536,
      'operatingTime': {'월': '10:00 - 20:00'},
      'description': '최고의 서비스',
      'image': 'https://example.com/image.jpg',
      'averageRating': 4.5,
      'reviewCount': 128,
      'categories': [
        {'id': 'cat-1', 'name': '헤어'}
      ],
      'distance': 1.2,
      'createdAt': '2025-01-01T00:00:00Z',
      'updatedAt': '2025-01-10T00:00:00Z',
    };

    final testPagedJson = {
      'items': [testShopJson, testShopJson],
      'hasNext': true,
      'totalElements': 100,
    };

    test('fromJson parses items correctly', () {
      final model = PagedBeautyShopsModel.fromJson(testPagedJson);
      expect(model.items.length, equals(2));
      expect(model.items.first, isA<BeautyShopModel>());
    });

    test('fromJson parses hasNext correctly', () {
      final model = PagedBeautyShopsModel.fromJson(testPagedJson);
      expect(model.hasNext, isTrue);
    });

    test('fromJson parses totalElements correctly', () {
      final model = PagedBeautyShopsModel.fromJson(testPagedJson);
      expect(model.totalElements, equals(100));
    });

    test('fromJson handles empty items', () {
      final emptyJson = {
        'items': [],
        'hasNext': false,
        'totalElements': 0,
      };
      final model = PagedBeautyShopsModel.fromJson(emptyJson);
      expect(model.items, isEmpty);
      expect(model.hasNext, isFalse);
      expect(model.totalElements, equals(0));
    });

    test('fromJson handles hasNext false', () {
      final lastPageJson = {
        'items': [testShopJson],
        'hasNext': false,
        'totalElements': 1,
      };
      final model = PagedBeautyShopsModel.fromJson(lastPageJson);
      expect(model.hasNext, isFalse);
    });

    test('items are BeautyShopModel instances', () {
      final model = PagedBeautyShopsModel.fromJson(testPagedJson);
      for (final item in model.items) {
        expect(item, isA<BeautyShopModel>());
      }
    });
  });
}
