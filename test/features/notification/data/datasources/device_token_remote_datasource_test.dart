import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/notification/data/datasources/device_token_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late DeviceTokenRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = DeviceTokenRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('registerToken', () {
    test('should POST to /api/device-tokens with token and platform', () async {
      when(() => mockApiClient.post(
            '/api/device-tokens',
            data: {'token': 'fcm-token-123', 'platform': 'IOS'},
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/device-tokens'),
            statusCode: 201,
          ));

      await dataSource.registerToken('fcm-token-123', 'IOS');

      verify(() => mockApiClient.post(
            '/api/device-tokens',
            data: {'token': 'fcm-token-123', 'platform': 'IOS'},
          )).called(1);
    });

    test('should throw on server error', () async {
      when(() => mockApiClient.post(
            '/api/device-tokens',
            data: {'token': 'bad', 'platform': 'ANDROID'},
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: '/api/device-tokens'),
          ));

      expect(
        () => dataSource.registerToken('bad', 'ANDROID'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('unregisterToken', () {
    test('should DELETE /api/device-tokens/{token}', () async {
      when(() => mockApiClient.delete('/api/device-tokens/fcm-token-123'))
          .thenAnswer((_) async => Response(
                requestOptions:
                    RequestOptions(path: '/api/device-tokens/fcm-token-123'),
                statusCode: 204,
              ));

      await dataSource.unregisterToken('fcm-token-123');

      verify(() => mockApiClient.delete('/api/device-tokens/fcm-token-123'))
          .called(1);
    });
  });
}
