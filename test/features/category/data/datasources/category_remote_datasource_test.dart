import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/category/data/datasources/category_remote_datasource.dart';
import 'package:jellomark/features/category/data/models/category_model.dart';

void main() {
  group('CategoryRemoteDataSource', () {
    late CategoryRemoteDataSource dataSource;
    late ApiClient apiClient;
    late DioAdapter dioAdapter;

    setUp(() {
      apiClient = ApiClient(baseUrl: 'https://api.example.com');
      dioAdapter = DioAdapter(dio: apiClient.dio);
      dataSource = CategoryRemoteDataSourceImpl(apiClient: apiClient);
    });

    group('getCategories', () {
      test('returns List<CategoryModel> on success', () async {
        dioAdapter.onGet(
          '/api/categories',
          (server) => server.reply(200, [
            {'id': 'cat-1', 'name': '헤어'},
            {'id': 'cat-2', 'name': '네일'},
          ]),
        );

        final result = await dataSource.getCategories();

        expect(result, isA<List<CategoryModel>>());
        expect(result.length, equals(2));
        expect(result[0].name, equals('헤어'));
        expect(result[1].name, equals('네일'));
      });

      test('returns empty list when no categories', () async {
        dioAdapter.onGet(
          '/api/categories',
          (server) => server.reply(200, []),
        );

        final result = await dataSource.getCategories();

        expect(result, isEmpty);
      });

      test('throws DioException on error', () async {
        dioAdapter.onGet(
          '/api/categories',
          (server) => server.reply(500, {'error': 'Server error'}),
        );

        expect(
          () => dataSource.getCategories(),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
