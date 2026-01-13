import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';

void main() {
  group('BeautyShopFilter', () {
    test('creates instance with default values', () {
      const filter = BeautyShopFilter();

      expect(filter.page, equals(0));
      expect(filter.size, equals(20));
      expect(filter.sortBy, isNull);
      expect(filter.sortOrder, isNull);
      expect(filter.categoryId, isNull);
      expect(filter.latitude, isNull);
      expect(filter.longitude, isNull);
      expect(filter.minRating, isNull);
    });

    test('creates instance with custom values', () {
      const filter = BeautyShopFilter(
        page: 1,
        size: 10,
        sortBy: 'RATING',
        sortOrder: 'DESC',
        categoryId: 'cat-1',
        latitude: 37.5065,
        longitude: 127.0536,
        minRating: 4.0,
      );

      expect(filter.page, equals(1));
      expect(filter.size, equals(10));
      expect(filter.sortBy, equals('RATING'));
      expect(filter.sortOrder, equals('DESC'));
      expect(filter.categoryId, equals('cat-1'));
      expect(filter.latitude, equals(37.5065));
      expect(filter.longitude, equals(127.0536));
      expect(filter.minRating, equals(4.0));
    });

    test('copyWith creates new instance with updated values', () {
      const filter = BeautyShopFilter(page: 0, size: 20);
      final updated = filter.copyWith(page: 1, sortBy: 'RATING');

      expect(updated.page, equals(1));
      expect(updated.size, equals(20));
      expect(updated.sortBy, equals('RATING'));
    });

    test('copyWith preserves unchanged values', () {
      const filter = BeautyShopFilter(
        page: 0,
        size: 20,
        categoryId: 'cat-1',
      );
      final updated = filter.copyWith(page: 1);

      expect(updated.categoryId, equals('cat-1'));
    });

    test('equality works correctly', () {
      const filter1 = BeautyShopFilter(page: 0, size: 20);
      const filter2 = BeautyShopFilter(page: 0, size: 20);

      expect(filter1, equals(filter2));
    });

    test('different values create unequal instances', () {
      const filter1 = BeautyShopFilter(page: 0, size: 20);
      const filter2 = BeautyShopFilter(page: 1, size: 20);

      expect(filter1, isNot(equals(filter2)));
    });
  });
}
