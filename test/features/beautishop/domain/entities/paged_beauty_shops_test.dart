import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';

void main() {
  group('PagedBeautyShops', () {
    const testShop = BeautyShop(
      id: 'shop-1',
      name: '뷰티살롱',
      address: '서울시 강남구',
    );

    test('creates instance with required fields', () {
      const paged = PagedBeautyShops(
        items: [testShop],
        hasNext: true,
        totalElements: 100,
      );

      expect(paged.items.length, equals(1));
      expect(paged.hasNext, isTrue);
      expect(paged.totalElements, equals(100));
    });

    test('items can be empty', () {
      const paged = PagedBeautyShops(
        items: [],
        hasNext: false,
        totalElements: 0,
      );

      expect(paged.items, isEmpty);
    });

    test('equality works correctly', () {
      const paged1 = PagedBeautyShops(
        items: [testShop],
        hasNext: true,
        totalElements: 100,
      );
      const paged2 = PagedBeautyShops(
        items: [testShop],
        hasNext: true,
        totalElements: 100,
      );

      expect(paged1, equals(paged2));
    });

    test('different totalElements creates unequal instances', () {
      const paged1 = PagedBeautyShops(
        items: [testShop],
        hasNext: true,
        totalElements: 100,
      );
      const paged2 = PagedBeautyShops(
        items: [testShop],
        hasNext: true,
        totalElements: 200,
      );

      expect(paged1, isNot(equals(paged2)));
    });
  });
}
