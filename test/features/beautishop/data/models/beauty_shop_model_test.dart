import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';

void main() {
  group('BeautyShopModel', () {
    final testJson = {
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'name': '뷰티살롱 강남',
      'regNum': '123-45-67890',
      'phoneNumber': '02-1234-5678',
      'address': '서울시 강남구 테헤란로 123',
      'latitude': 37.5065,
      'longitude': 127.0536,
      'operatingTime': {
        '월': '10:00 - 20:00',
        '화': '10:00 - 20:00',
        '수': '10:00 - 20:00',
        '목': '10:00 - 20:00',
        '금': '10:00 - 21:00',
        '토': '10:00 - 18:00',
        '일': '휴무',
      },
      'description': '최고의 뷰티 서비스를 제공합니다.',
      'image': 'https://example.com/image.jpg',
      'averageRating': 4.5,
      'reviewCount': 128,
      'categories': [
        {'id': 'cat-1', 'name': '헤어'},
        {'id': 'cat-2', 'name': '네일'},
      ],
      'distance': 1.2,
      'createdAt': '2025-01-01T00:00:00Z',
      'updatedAt': '2025-01-10T00:00:00Z',
    };

    test('extends BeautyShop', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model, isA<BeautyShop>());
    });

    test('fromJson parses id correctly', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.id, equals('550e8400-e29b-41d4-a716-446655440000'));
    });

    test('fromJson parses name correctly', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.name, equals('뷰티살롱 강남'));
    });

    test('fromJson parses address correctly', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.address, equals('서울시 강남구 테헤란로 123'));
    });

    test('fromJson parses coordinates correctly', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.latitude, equals(37.5065));
      expect(model.longitude, equals(127.0536));
    });

    test('fromJson parses image as imageUrl', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.imageUrl, equals('https://example.com/image.jpg'));
    });

    test('fromJson parses averageRating as rating', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.rating, equals(4.5));
    });

    test('fromJson parses reviewCount correctly', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.reviewCount, equals(128));
    });

    test('fromJson parses distance correctly', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.distance, equals(1.2));
    });

    test('fromJson extracts category names as tags', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.tags, equals(['헤어', '네일']));
    });

    test('fromJson formats operatingTime as operatingHours string', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.operatingHours, isNotNull);
      expect(model.operatingHours, contains('월'));
    });

    test('fromJson handles null image', () {
      final jsonWithNullImage = Map<String, dynamic>.from(testJson);
      jsonWithNullImage['image'] = null;
      final model = BeautyShopModel.fromJson(jsonWithNullImage);
      expect(model.imageUrl, isNull);
    });

    test('fromJson handles null distance', () {
      final jsonWithNullDistance = Map<String, dynamic>.from(testJson);
      jsonWithNullDistance['distance'] = null;
      final model = BeautyShopModel.fromJson(jsonWithNullDistance);
      expect(model.distance, isNull);
    });

    test('fromJson handles null description', () {
      final jsonWithNullDescription = Map<String, dynamic>.from(testJson);
      jsonWithNullDescription['description'] = null;
      final model = BeautyShopModel.fromJson(jsonWithNullDescription);
      expect(model, isA<BeautyShopModel>());
    });

    test('fromJson handles empty categories', () {
      final jsonWithEmptyCategories = Map<String, dynamic>.from(testJson);
      jsonWithEmptyCategories['categories'] = [];
      final model = BeautyShopModel.fromJson(jsonWithEmptyCategories);
      expect(model.tags, isEmpty);
    });

    test('isNew is true for shops created within 30 days', () {
      final recentJson = Map<String, dynamic>.from(testJson);
      recentJson['createdAt'] = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
      final model = BeautyShopModel.fromJson(recentJson);
      expect(model.isNew, isTrue);
    });

    test('isNew is false for shops created more than 30 days ago', () {
      final oldJson = Map<String, dynamic>.from(testJson);
      oldJson['createdAt'] = DateTime.now().subtract(const Duration(days: 60)).toIso8601String();
      final model = BeautyShopModel.fromJson(oldJson);
      expect(model.isNew, isFalse);
    });

    test('toJson converts model back to JSON', () {
      final model = BeautyShopModel.fromJson(testJson);
      final json = model.toJson();
      expect(json['id'], equals(model.id));
      expect(json['name'], equals(model.name));
      expect(json['address'], equals(model.address));
    });

    test('phoneNumber is accessible', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.phoneNumber, equals('02-1234-5678'));
    });

    test('description is accessible', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.description, equals('최고의 뷰티 서비스를 제공합니다.'));
    });

    test('operatingTimeMap is accessible', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.operatingTimeMap, isA<Map<String, String>>());
      expect(model.operatingTimeMap['월'], equals('10:00 - 20:00'));
    });

    test('createdAt is accessible', () {
      final model = BeautyShopModel.fromJson(testJson);
      expect(model.createdAt, isA<DateTime>());
    });
  });
}
