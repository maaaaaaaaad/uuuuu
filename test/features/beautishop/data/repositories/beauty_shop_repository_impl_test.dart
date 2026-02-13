import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/data/datasources/beauty_shop_remote_datasource.dart';
import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';
import 'package:jellomark/features/beautishop/data/models/paged_beauty_shops_model.dart';
import 'package:jellomark/features/beautishop/data/repositories/beauty_shop_repository_impl.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockBeautyShopRemoteDataSource extends Mock
    implements BeautyShopRemoteDataSource {}

void main() {
  group('BeautyShopRepositoryImpl', () {
    late BeautyShopRepository repository;
    late MockBeautyShopRemoteDataSource mockRemoteDataSource;

    final testShopModel = BeautyShopModel.fromJson({
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
        {'id': 'cat-1', 'name': '헤어'},
      ],
      'distance': 1.2,
      'createdAt': '2025-01-01T00:00:00Z',
      'updatedAt': '2025-01-10T00:00:00Z',
    });

    setUp(() {
      mockRemoteDataSource = MockBeautyShopRemoteDataSource();
      repository = BeautyShopRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    group('getBeautyShops', () {
      test('returns Right(PagedBeautyShops) on success', () async {
        final pagedModel = PagedBeautyShopsModel(
          items: [testShopModel],
          hasNext: true,
          totalElements: 100,
        );

        when(
          () => mockRemoteDataSource.getBeautyShops(
            page: any(named: 'page'),
            size: any(named: 'size'),
            keyword: any(named: 'keyword'),
            sortBy: any(named: 'sortBy'),
            sortOrder: any(named: 'sortOrder'),
            categoryId: any(named: 'categoryId'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            minRating: any(named: 'minRating'),
          ),
        ).thenAnswer((_) async => pagedModel);

        final result = await repository.getBeautyShops(page: 0, size: 20);

        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Should not return failure'), (paged) {
          expect(paged, isA<PagedBeautyShops>());
          expect(paged.items.length, equals(1));
          expect(paged.hasNext, isTrue);
          expect(paged.totalElements, equals(100));
        });
      });

      test('passes filter parameters to data source', () async {
        final pagedModel = PagedBeautyShopsModel(
          items: [testShopModel],
          hasNext: false,
          totalElements: 1,
        );

        when(
          () => mockRemoteDataSource.getBeautyShops(
            page: 0,
            size: 20,
            keyword: null,
            sortBy: 'RATING',
            sortOrder: 'DESC',
            categoryId: 'cat-1',
            latitude: 37.5065,
            longitude: 127.0536,
            minRating: 4.0,
          ),
        ).thenAnswer((_) async => pagedModel);

        await repository.getBeautyShops(
          page: 0,
          size: 20,
          sortBy: 'RATING',
          sortOrder: 'DESC',
          categoryId: 'cat-1',
          latitude: 37.5065,
          longitude: 127.0536,
          minRating: 4.0,
        );

        verify(
          () => mockRemoteDataSource.getBeautyShops(
            page: 0,
            size: 20,
            keyword: null,
            sortBy: 'RATING',
            sortOrder: 'DESC',
            categoryId: 'cat-1',
            latitude: 37.5065,
            longitude: 127.0536,
            minRating: 4.0,
          ),
        ).called(1);
      });

      test('returns Left(ServerFailure) on DioException', () async {
        when(
          () => mockRemoteDataSource.getBeautyShops(
            page: any(named: 'page'),
            size: any(named: 'size'),
            keyword: any(named: 'keyword'),
            sortBy: any(named: 'sortBy'),
            sortOrder: any(named: 'sortOrder'),
            categoryId: any(named: 'categoryId'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            minRating: any(named: 'minRating'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/beautishops'),
            message: 'Server error',
          ),
        );

        final result = await repository.getBeautyShops(page: 0, size: 20);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (paged) => fail('Should not return success'),
        );
      });
    });

    group('getBeautyShopById', () {
      test('returns Right(BeautyShop) on success', () async {
        when(
          () => mockRemoteDataSource.getBeautyShopById(any()),
        ).thenAnswer((_) async => testShopModel);

        final result = await repository.getBeautyShopById('shop-id');

        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Should not return failure'), (shop) {
          expect(shop.id, equals('550e8400-e29b-41d4-a716-446655440000'));
          expect(shop.name, equals('뷰티살롱 강남'));
        });
      });

      test('returns Left(ServerFailure) on DioException', () async {
        when(() => mockRemoteDataSource.getBeautyShopById(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/beautishops/id'),
            message: 'Not found',
          ),
        );

        final result = await repository.getBeautyShopById('non-existent');

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (shop) => fail('Should not return success'),
        );
      });
    });

    group('getRecommendedShops', () {
      test('calls getBeautyShops with RATING sortBy', () async {
        final pagedModel = PagedBeautyShopsModel(
          items: [testShopModel],
          hasNext: false,
          totalElements: 1,
        );

        when(
          () => mockRemoteDataSource.getBeautyShops(
            page: 0,
            size: 10,
            keyword: null,
            sortBy: 'RATING',
            sortOrder: 'DESC',
            categoryId: null,
            latitude: null,
            longitude: null,
            minRating: null,
          ),
        ).thenAnswer((_) async => pagedModel);

        final result = await repository.getRecommendedShops();

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (shops) => expect(shops.length, equals(1)),
        );
      });
    });

    group('getNewShops', () {
      test('calls getBeautyShops with CREATED_AT sortBy', () async {
        final pagedModel = PagedBeautyShopsModel(
          items: [testShopModel],
          hasNext: false,
          totalElements: 1,
        );

        when(
          () => mockRemoteDataSource.getBeautyShops(
            page: 0,
            size: 10,
            keyword: null,
            sortBy: 'CREATED_AT',
            sortOrder: 'DESC',
            categoryId: null,
            latitude: null,
            longitude: null,
            minRating: null,
          ),
        ).thenAnswer((_) async => pagedModel);

        final result = await repository.getNewShops();

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (shops) => expect(shops.length, equals(1)),
        );
      });
    });

    group('getNearbyShops', () {
      test('calls getBeautyShops with location parameters', () async {
        final pagedModel = PagedBeautyShopsModel(
          items: [testShopModel],
          hasNext: false,
          totalElements: 1,
        );

        when(
          () => mockRemoteDataSource.getBeautyShops(
            page: 0,
            size: 100,
            keyword: null,
            sortBy: 'DISTANCE',
            sortOrder: 'ASC',
            categoryId: null,
            latitude: 37.5065,
            longitude: 127.0536,
            minRating: null,
            radiusKm: null,
          ),
        ).thenAnswer((_) async => pagedModel);

        final result = await repository.getNearbyShops(
          latitude: 37.5065,
          longitude: 127.0536,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (shops) => expect(shops.length, equals(1)),
        );
      });
    });
  });
}
