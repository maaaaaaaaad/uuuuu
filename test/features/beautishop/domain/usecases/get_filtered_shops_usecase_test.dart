import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockBeautyShopRepository extends Mock implements BeautyShopRepository {}

void main() {
  group('GetFilteredShopsUseCase', () {
    late GetFilteredShopsUseCase useCase;
    late MockBeautyShopRepository mockRepository;

    setUp(() {
      mockRepository = MockBeautyShopRepository();
      useCase = GetFilteredShopsUseCase(repository: mockRepository);
    });

    const testShop = BeautyShop(
      id: 'shop-1',
      name: '뷰티살롱',
      address: '서울시 강남구',
    );

    test('calls repository with filter parameters', () async {
      const filter = BeautyShopFilter(
        page: 0,
        size: 20,
        sortBy: 'RATING',
        sortOrder: 'DESC',
      );

      const pagedShops = PagedBeautyShops(
        items: [testShop],
        hasNext: true,
        totalElements: 100,
      );

      when(
        () => mockRepository.getBeautyShops(
          page: filter.page,
          size: filter.size,
          sortBy: filter.sortBy,
          sortOrder: filter.sortOrder,
          categoryId: filter.categoryId,
          latitude: filter.latitude,
          longitude: filter.longitude,
          minRating: filter.minRating,
        ),
      ).thenAnswer((_) async => const Right(pagedShops));

      final result = await useCase(filter);

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (paged) {
          expect(paged.items.length, equals(1));
          expect(paged.hasNext, isTrue);
          expect(paged.totalElements, equals(100));
        },
      );

      verify(
        () => mockRepository.getBeautyShops(
          page: 0,
          size: 20,
          sortBy: 'RATING',
          sortOrder: 'DESC',
          categoryId: null,
          latitude: null,
          longitude: null,
          minRating: null,
        ),
      ).called(1);
    });

    test('returns failure from repository', () async {
      const filter = BeautyShopFilter();

      when(
        () => mockRepository.getBeautyShops(
          page: any(named: 'page'),
          size: any(named: 'size'),
          sortBy: any(named: 'sortBy'),
          sortOrder: any(named: 'sortOrder'),
          categoryId: any(named: 'categoryId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          minRating: any(named: 'minRating'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase(filter);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (paged) => fail('Should not return success'),
      );
    });

    test('passes all filter parameters correctly', () async {
      const filter = BeautyShopFilter(
        page: 1,
        size: 10,
        sortBy: 'CREATED_AT',
        sortOrder: 'ASC',
        categoryId: 'cat-1',
        latitude: 37.5065,
        longitude: 127.0536,
        minRating: 4.0,
      );

      const pagedShops = PagedBeautyShops(
        items: [],
        hasNext: false,
        totalElements: 0,
      );

      when(
        () => mockRepository.getBeautyShops(
          page: 1,
          size: 10,
          sortBy: 'CREATED_AT',
          sortOrder: 'ASC',
          categoryId: 'cat-1',
          latitude: 37.5065,
          longitude: 127.0536,
          minRating: 4.0,
        ),
      ).thenAnswer((_) async => const Right(pagedShops));

      await useCase(filter);

      verify(
        () => mockRepository.getBeautyShops(
          page: 1,
          size: 10,
          sortBy: 'CREATED_AT',
          sortOrder: 'ASC',
          categoryId: 'cat-1',
          latitude: 37.5065,
          longitude: 127.0536,
          minRating: 4.0,
        ),
      ).called(1);
    });
  });
}
