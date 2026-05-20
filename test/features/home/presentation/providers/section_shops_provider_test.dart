import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/home/domain/entities/home_section.dart';
import 'package:jellomark/features/home/presentation/providers/section_shops_provider.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFilteredShopsUseCase extends Mock
    implements GetFilteredShopsUseCase {}

class FakeBeautyShopFilter extends Fake implements BeautyShopFilter {}

BeautyShop _shop(String id) => BeautyShop(
  id: id,
  name: 'Shop $id',
  address: 'Address $id',
  latitude: 37.5,
  longitude: 127.0,
);

PagedBeautyShops _page(List<String> ids, {required bool hasNext}) =>
    PagedBeautyShops(
      items: ids.map(_shop).toList(),
      hasNext: hasNext,
      totalElements: ids.length,
    );

void main() {
  late MockGetFilteredShopsUseCase useCase;
  late List<BeautyShopFilter> capturedFilters;

  setUpAll(() => registerFallbackValue(FakeBeautyShopFilter()));

  setUp(() {
    useCase = MockGetFilteredShopsUseCase();
    capturedFilters = [];
  });

  SectionShopsNotifier build(HomeSection section, {UserLocation? location}) {
    return SectionShopsNotifier(
      section: section,
      useCase: useCase,
      getCurrentLocation: () async => location,
    );
  }

  void stubPages(List<PagedBeautyShops> pages) {
    var call = 0;
    when(() => useCase(any())).thenAnswer((invocation) async {
      capturedFilters.add(
        invocation.positionalArguments[0] as BeautyShopFilter,
      );
      final result = pages[call < pages.length ? call : pages.length - 1];
      call++;
      return Right(result);
    });
  }

  group('HomeSection', () {
    test('maps default sort per concept', () {
      expect(HomeSection.nearbyPopular.defaultSort, ShopSortOption.distance);
      expect(HomeSection.recommended.defaultSort, ShopSortOption.rating);
      expect(HomeSection.newShops.defaultSort, ShopSortOption.latest);
    });

    test('only nearbyPopular enforces a minimum rating', () {
      expect(HomeSection.nearbyPopular.minRating, 4.0);
      expect(HomeSection.recommended.minRating, isNull);
      expect(HomeSection.newShops.minRating, isNull);
    });
  });

  group('SectionShopsNotifier', () {
    test('initial state uses the section default sort and empty list', () {
      final notifier = build(HomeSection.recommended);
      expect(notifier.state.sort, ShopSortOption.rating);
      expect(notifier.state.shops, isEmpty);
      expect(notifier.state.page, 0);
    });

    test('loadInitial populates shops and hasMore from first page', () async {
      stubPages([
        _page(['1', '2'], hasNext: true),
      ]);
      final notifier = build(HomeSection.recommended);

      await notifier.loadInitial();

      expect(notifier.state.shops.map((s) => s.id), ['1', '2']);
      expect(notifier.state.hasMore, isTrue);
      expect(notifier.state.isLoading, isFalse);
      expect(capturedFilters.single.sortBy, 'RATING');
      expect(capturedFilters.single.page, 0);
    });

    test('nearbyPopular sends minRating and distance coordinates', () async {
      stubPages([
        _page(['1'], hasNext: false),
      ]);
      final notifier = build(
        HomeSection.nearbyPopular,
        location: const UserLocation(latitude: 37.1, longitude: 127.2),
      );

      await notifier.loadInitial();

      final filter = capturedFilters.single;
      expect(filter.sortBy, 'DISTANCE');
      expect(filter.minRating, 4.0);
      expect(filter.latitude, 37.1);
      expect(filter.longitude, 127.2);
    });

    test('loadMore appends the next page and increments page', () async {
      stubPages([
        _page(['1', '2'], hasNext: true),
        _page(['3', '4'], hasNext: false),
      ]);
      final notifier = build(HomeSection.recommended);

      await notifier.loadInitial();
      await notifier.loadMore();

      expect(notifier.state.shops.map((s) => s.id), ['1', '2', '3', '4']);
      expect(notifier.state.page, 1);
      expect(notifier.state.hasMore, isFalse);
      expect(capturedFilters.last.page, 1);
    });

    test('loadMore is a no-op when hasMore is false', () async {
      stubPages([
        _page(['1'], hasNext: false),
      ]);
      final notifier = build(HomeSection.recommended);

      await notifier.loadInitial();
      await notifier.loadMore();

      expect(capturedFilters.length, 1);
    });

    test('changeSort resets the list and reloads with the new sort', () async {
      stubPages([
        _page(['1', '2'], hasNext: true),
        _page(['9'], hasNext: false),
      ]);
      final notifier = build(HomeSection.recommended);

      await notifier.loadInitial();
      await notifier.changeSort(ShopSortOption.reviewCount);

      expect(notifier.state.sort, ShopSortOption.reviewCount);
      expect(notifier.state.shops.map((s) => s.id), ['9']);
      expect(notifier.state.page, 0);
      expect(capturedFilters.last.sortBy, 'REVIEW_COUNT');
    });

    test('changeSort to the current sort does not refetch', () async {
      stubPages([
        _page(['1'], hasNext: false),
      ]);
      final notifier = build(HomeSection.recommended);

      await notifier.loadInitial();
      await notifier.changeSort(ShopSortOption.rating);

      expect(capturedFilters.length, 1);
    });

    test('exposes error message on failure', () async {
      when(
        () => useCase(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('실패')));
      final notifier = build(HomeSection.recommended);

      await notifier.loadInitial();

      expect(notifier.state.error, '실패');
      expect(notifier.state.isLoading, isFalse);
    });
  });
}
