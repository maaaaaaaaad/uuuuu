import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/usage_history/data/datasources/usage_history_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late UsageHistoryRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = UsageHistoryRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  final tJsonList = [
    {
      'id': 'uh-1',
      'memberId': 'member-1',
      'shopId': 'shop-1',
      'reservationId': 'reservation-1',
      'shopName': '젤로네일',
      'treatmentName': '젤네일',
      'treatmentPrice': 30000,
      'treatmentDuration': 60,
      'completedAt': '2026-01-15T14:00:00Z',
      'createdAt': '2026-01-15T14:00:00Z',
    },
  ];

  group('getMyUsageHistory', () {
    test('should return list of UsageHistoryModel when API call is successful',
        () async {
      when(() => mockApiClient.get<List<dynamic>>(any())).thenAnswer(
        (_) async => Response(
          data: tJsonList,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await dataSource.getMyUsageHistory();

      expect(result.length, 1);
      expect(result.first.id, 'uh-1');
      expect(result.first.shopName, '젤로네일');
      verify(() => mockApiClient.get<List<dynamic>>('/api/usage-history/me'))
          .called(1);
    });

    test('should return empty list when no usage history', () async {
      when(() => mockApiClient.get<List<dynamic>>(any())).thenAnswer(
        (_) async => Response(
          data: <dynamic>[],
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await dataSource.getMyUsageHistory();

      expect(result, isEmpty);
    });
  });
}
