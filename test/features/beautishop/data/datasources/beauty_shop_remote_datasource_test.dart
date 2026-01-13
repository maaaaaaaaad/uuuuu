import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/beautishop/data/datasources/beauty_shop_remote_datasource.dart';
import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';
import 'package:jellomark/features/beautishop/data/models/paged_beauty_shops_model.dart';

void main() {
  group('BeautyShopRemoteDataSource', () {
    late BeautyShopRemoteDataSource dataSource;
    late ApiClient apiClient;
    late DioAdapter dioAdapter;

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

    setUp(() {
      apiClient = ApiClient(baseUrl: 'https://api.example.com');
      dioAdapter = DioAdapter(dio: apiClient.dio);
      dataSource = BeautyShopRemoteDataSourceImpl(apiClient: apiClient);
    });

    group('getBeautyShops', () {
      test('returns PagedBeautyShopsModel on successful response', () async {
        dioAdapter.onGet(
          '/api/beautishops',
          (server) => server.reply(200, {
            'items': [testShopJson],
            'hasNext': true,
            'totalElements': 100,
          }),
          queryParameters: {'page': 0, 'size': 20},
        );

        final result = await dataSource.getBeautyShops(page: 0, size: 20);

        expect(result, isA<PagedBeautyShopsModel>());
        expect(result.items.length, equals(1));
        expect(result.hasNext, isTrue);
        expect(result.totalElements, equals(100));
      });

      test('passes sortBy parameter correctly', () async {
        dioAdapter.onGet(
          '/api/beautishops',
          (server) => server.reply(200, {
            'items': [testShopJson],
            'hasNext': false,
            'totalElements': 1,
          }),
          queryParameters: {'page': 0, 'size': 20, 'sortBy': 'RATING'},
        );

        final result = await dataSource.getBeautyShops(
          page: 0,
          size: 20,
          sortBy: 'RATING',
        );

        expect(result, isA<PagedBeautyShopsModel>());
      });

      test('passes sortOrder parameter correctly', () async {
        dioAdapter.onGet(
          '/api/beautishops',
          (server) => server.reply(200, {
            'items': [testShopJson],
            'hasNext': false,
            'totalElements': 1,
          }),
          queryParameters: {
            'page': 0,
            'size': 20,
            'sortBy': 'RATING',
            'sortOrder': 'DESC',
          },
        );

        final result = await dataSource.getBeautyShops(
          page: 0,
          size: 20,
          sortBy: 'RATING',
          sortOrder: 'DESC',
        );

        expect(result, isA<PagedBeautyShopsModel>());
      });

      test('passes categoryId parameter correctly', () async {
        dioAdapter.onGet(
          '/api/beautishops',
          (server) => server.reply(200, {
            'items': [testShopJson],
            'hasNext': false,
            'totalElements': 1,
          }),
          queryParameters: {'page': 0, 'size': 20, 'categoryId': 'cat-1'},
        );

        final result = await dataSource.getBeautyShops(
          page: 0,
          size: 20,
          categoryId: 'cat-1',
        );

        expect(result, isA<PagedBeautyShopsModel>());
      });

      test('passes location parameters correctly', () async {
        dioAdapter.onGet(
          '/api/beautishops',
          (server) => server.reply(200, {
            'items': [testShopJson],
            'hasNext': false,
            'totalElements': 1,
          }),
          queryParameters: {
            'page': 0,
            'size': 20,
            'latitude': 37.5065,
            'longitude': 127.0536,
          },
        );

        final result = await dataSource.getBeautyShops(
          page: 0,
          size: 20,
          latitude: 37.5065,
          longitude: 127.0536,
        );

        expect(result, isA<PagedBeautyShopsModel>());
      });

      test('passes minRating parameter correctly', () async {
        dioAdapter.onGet(
          '/api/beautishops',
          (server) => server.reply(200, {
            'items': [testShopJson],
            'hasNext': false,
            'totalElements': 1,
          }),
          queryParameters: {'page': 0, 'size': 20, 'minRating': 4.0},
        );

        final result = await dataSource.getBeautyShops(
          page: 0,
          size: 20,
          minRating: 4.0,
        );

        expect(result, isA<PagedBeautyShopsModel>());
      });

      test('throws DioException on error response', () async {
        dioAdapter.onGet(
          '/api/beautishops',
          (server) => server.reply(500, {'error': 'Internal Server Error'}),
          queryParameters: {'page': 0, 'size': 20},
        );

        expect(
          () => dataSource.getBeautyShops(page: 0, size: 20),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getBeautyShopById', () {
      test('returns BeautyShopModel on successful response', () async {
        dioAdapter.onGet(
          '/api/beautishops/550e8400-e29b-41d4-a716-446655440000',
          (server) => server.reply(200, testShopJson),
        );

        final result = await dataSource.getBeautyShopById(
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(result, isA<BeautyShopModel>());
        expect(result.id, equals('550e8400-e29b-41d4-a716-446655440000'));
        expect(result.name, equals('뷰티살롱 강남'));
      });

      test('throws DioException on 404 response', () async {
        dioAdapter.onGet(
          '/api/beautishops/non-existent-id',
          (server) => server.reply(404, {'error': 'Not Found'}),
        );

        expect(
          () => dataSource.getBeautyShopById('non-existent-id'),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
