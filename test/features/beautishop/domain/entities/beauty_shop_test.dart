import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';

void main() {
  group('BeautyShop', () {
    test('creates instance with required fields', () {
      const shop = BeautyShop(
        id: '1',
        name: '네일샵 A',
        address: '서울시 강남구',
      );

      expect(shop.id, '1');
      expect(shop.name, '네일샵 A');
      expect(shop.address, '서울시 강남구');
    });

    test('creates instance with all fields', () {
      const shop = BeautyShop(
        id: '1',
        name: '네일샵 A',
        address: '서울시 강남구',
        latitude: 37.5172,
        longitude: 127.0473,
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.5,
        reviewCount: 120,
        distance: 1.2,
        tags: ['네일', '젤네일'],
        discountRate: 20,
        isNew: true,
        operatingHours: '10:00 - 22:00',
      );

      expect(shop.latitude, 37.5172);
      expect(shop.longitude, 127.0473);
      expect(shop.imageUrl, 'https://example.com/image.jpg');
      expect(shop.rating, 4.5);
      expect(shop.reviewCount, 120);
      expect(shop.distance, 1.2);
      expect(shop.tags, ['네일', '젤네일']);
      expect(shop.discountRate, 20);
      expect(shop.isNew, true);
      expect(shop.operatingHours, '10:00 - 22:00');
    });

    test('has default values for optional fields', () {
      const shop = BeautyShop(
        id: '1',
        name: '네일샵 A',
        address: '서울시 강남구',
      );

      expect(shop.latitude, isNull);
      expect(shop.longitude, isNull);
      expect(shop.imageUrl, isNull);
      expect(shop.rating, 0.0);
      expect(shop.reviewCount, 0);
      expect(shop.distance, isNull);
      expect(shop.tags, isEmpty);
      expect(shop.discountRate, isNull);
      expect(shop.isNew, false);
      expect(shop.operatingHours, isNull);
    });

    test('supports value equality', () {
      const shop1 = BeautyShop(
        id: '1',
        name: '네일샵 A',
        address: '서울시 강남구',
      );
      const shop2 = BeautyShop(
        id: '1',
        name: '네일샵 A',
        address: '서울시 강남구',
      );

      expect(shop1, equals(shop2));
    });

    test('formattedDistance returns distance with km suffix', () {
      const shop = BeautyShop(
        id: '1',
        name: '네일샵 A',
        address: '서울시 강남구',
        distance: 1.5,
      );

      expect(shop.formattedDistance, '1.5km');
    });

    test('formattedDistance returns m for distances under 1km', () {
      const shop = BeautyShop(
        id: '1',
        name: '네일샵 A',
        address: '서울시 강남구',
        distance: 0.5,
      );

      expect(shop.formattedDistance, '500m');
    });

    test('formattedRating returns rating with one decimal', () {
      const shop = BeautyShop(
        id: '1',
        name: '네일샵 A',
        address: '서울시 강남구',
        rating: 4.567,
      );

      expect(shop.formattedRating, '4.6');
    });
  });
}
