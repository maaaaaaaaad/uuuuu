import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/home/domain/entities/home_section.dart';

void main() {
  group('HomeSection', () {
    test('each section maps to its concept-appropriate default sort', () {
      expect(HomeSection.nearbyPopular.defaultSort, ShopSortOption.distance);
      expect(HomeSection.recommended.defaultSort, ShopSortOption.rating);
      expect(HomeSection.newShops.defaultSort, ShopSortOption.latest);
    });

    test('only nearbyPopular enforces a minimum rating', () {
      expect(HomeSection.nearbyPopular.minRating, 4.0);
      expect(HomeSection.recommended.minRating, isNull);
      expect(HomeSection.newShops.minRating, isNull);
    });

    test('each section exposes a Korean title', () {
      expect(HomeSection.nearbyPopular.title, '내 주변 인기 샵');
      expect(HomeSection.recommended.title, '추천 샵');
      expect(HomeSection.newShops.title, '새로 입점한 샵');
    });
  });

  group('ShopSortOption', () {
    test('maps to backend sortBy and sortOrder', () {
      expect(ShopSortOption.distance.sortBy, 'DISTANCE');
      expect(ShopSortOption.distance.sortOrder, 'ASC');
      expect(ShopSortOption.rating.sortBy, 'RATING');
      expect(ShopSortOption.reviewCount.sortBy, 'REVIEW_COUNT');
      expect(ShopSortOption.latest.sortBy, 'CREATED_AT');
    });

    test('only distance requires location', () {
      expect(ShopSortOption.distance.requiresLocation, isTrue);
      expect(ShopSortOption.rating.requiresLocation, isFalse);
      expect(ShopSortOption.reviewCount.requiresLocation, isFalse);
      expect(ShopSortOption.latest.requiresLocation, isFalse);
    });
  });
}
