import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:jellomark/features/treatment/data/models/treatment_model.dart';

void main() {
  group('TreatmentRemoteDataSource', () {
    late TreatmentRemoteDataSource dataSource;
    late ApiClient apiClient;
    late DioAdapter dioAdapter;

    final testTreatmentJson = {
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'shopId': '660e8400-e29b-41d4-a716-446655440000',
      'name': '젤네일 풀세트',
      'price': 50000,
      'duration': 90,
      'description': '고급 젤네일 풀세트 시술입니다.',
      'createdAt': '2025-01-01T00:00:00Z',
      'updatedAt': '2025-01-10T00:00:00Z',
    };

    setUp(() {
      apiClient = ApiClient(baseUrl: 'https://api.example.com');
      dioAdapter = DioAdapter(dio: apiClient.dio);
      dataSource = TreatmentRemoteDataSourceImpl(apiClient: apiClient);
    });

    group('getShopTreatments', () {
      test('returns list of TreatmentModel on successful response', () async {
        dioAdapter.onGet(
          '/api/beautishops/660e8400-e29b-41d4-a716-446655440000/treatments',
          (server) => server.reply(200, [testTreatmentJson]),
        );

        final result = await dataSource.getShopTreatments(
          '660e8400-e29b-41d4-a716-446655440000',
        );

        expect(result, isA<List<TreatmentModel>>());
        expect(result.length, equals(1));
        expect(result.first.name, equals('젤네일 풀세트'));
      });

      test('returns empty list when no treatments', () async {
        dioAdapter.onGet(
          '/api/beautishops/660e8400-e29b-41d4-a716-446655440000/treatments',
          (server) => server.reply(200, []),
        );

        final result = await dataSource.getShopTreatments(
          '660e8400-e29b-41d4-a716-446655440000',
        );

        expect(result, isEmpty);
      });

      test('throws DioException on error response', () async {
        dioAdapter.onGet(
          '/api/beautishops/660e8400-e29b-41d4-a716-446655440000/treatments',
          (server) => server.reply(500, {'error': 'Internal Server Error'}),
        );

        expect(
          () => dataSource.getShopTreatments(
            '660e8400-e29b-41d4-a716-446655440000',
          ),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getTreatmentById', () {
      test('returns TreatmentModel on successful response', () async {
        dioAdapter.onGet(
          '/api/treatments/550e8400-e29b-41d4-a716-446655440000',
          (server) => server.reply(200, testTreatmentJson),
        );

        final result = await dataSource.getTreatmentById(
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(result, isA<TreatmentModel>());
        expect(result.id, equals('550e8400-e29b-41d4-a716-446655440000'));
        expect(result.name, equals('젤네일 풀세트'));
        expect(result.price, equals(50000));
        expect(result.durationMinutes, equals(90));
      });

      test('throws DioException on 404 response', () async {
        dioAdapter.onGet(
          '/api/treatments/non-existent-id',
          (server) => server.reply(404, {'error': 'Not Found'}),
        );

        expect(
          () => dataSource.getTreatmentById('non-existent-id'),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
