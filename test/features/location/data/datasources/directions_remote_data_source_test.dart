import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jellomark/features/location/data/datasources/directions_remote_data_source.dart';
import 'package:jellomark/features/location/data/models/directions_response_model.dart';

void main() {
  group('DirectionsRemoteDataSource', () {
    late DirectionsRemoteDataSource dataSource;
    late Dio dio;
    late DioAdapter dioAdapter;

    const baseUrl = 'https://naveropenapi.apigw.ntruss.com';
    const endpoint = '/map-direction/v1/driving';

    final successResponseJson = {
      'code': 0,
      'message': 'success',
      'route': {
        'traoptimal': [
          {
            'path': [
              [127.123, 37.456],
              [127.124, 37.457],
            ],
            'summary': {'distance': 1234, 'duration': 600000},
          },
        ],
      },
    };

    final errorResponseJson = {
      'code': 1,
      'message': 'Route not found',
      'route': null,
    };

    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter(dio: dio);
      dataSource = DirectionsRemoteDataSourceImpl.withDio(dio);
    });

    group('getDirections', () {
      test('returns DirectionsResponseModel on success', () async {
        dioAdapter.onGet(
          '$baseUrl$endpoint',
          (server) => server.reply(200, successResponseJson),
          queryParameters: {
            'start': '127.0,37.0',
            'goal': '127.5,37.5',
            'option': 'trafast',
          },
        );

        final result = await dataSource.getDirections(
          startLat: 37.0,
          startLng: 127.0,
          endLat: 37.5,
          endLng: 127.5,
        );

        expect(result, isA<DirectionsResponseModel>());
        expect(result.isSuccess, isTrue);
        expect(result.coordinates, isNotNull);
        expect(result.coordinates!.length, equals(2));
      });

      test('formats coordinates as lng,lat (longitude first)', () async {
        dioAdapter.onGet(
          '$baseUrl$endpoint',
          (server) => server.reply(200, successResponseJson),
          queryParameters: {
            'start': '126.123,37.456',
            'goal': '127.789,38.012',
            'option': 'trafast',
          },
        );

        final result = await dataSource.getDirections(
          startLat: 37.456,
          startLng: 126.123,
          endLat: 38.012,
          endLng: 127.789,
        );

        expect(result, isA<DirectionsResponseModel>());
      });

      test(
        'returns error response model when API returns error code',
        () async {
          dioAdapter.onGet(
            '$baseUrl$endpoint',
            (server) => server.reply(200, errorResponseJson),
            queryParameters: {
              'start': '127.0,37.0',
              'goal': '127.5,37.5',
              'option': 'trafast',
            },
          );

          final result = await dataSource.getDirections(
            startLat: 37.0,
            startLng: 127.0,
            endLat: 37.5,
            endLng: 127.5,
          );

          expect(result, isA<DirectionsResponseModel>());
          expect(result.isSuccess, isFalse);
          expect(result.code, equals(1));
          expect(result.message, equals('Route not found'));
        },
      );

      test('throws DioException on HTTP error', () async {
        dioAdapter.onGet(
          '$baseUrl$endpoint',
          (server) => server.reply(500, {'error': 'Internal Server Error'}),
          queryParameters: {
            'start': '127.0,37.0',
            'goal': '127.5,37.5',
            'option': 'trafast',
          },
        );

        expect(
          () => dataSource.getDirections(
            startLat: 37.0,
            startLng: 127.0,
            endLat: 37.5,
            endLng: 127.5,
          ),
          throwsA(isA<DioException>()),
        );
      });

      test('throws DioException on network error', () async {
        dioAdapter.onGet(
          '$baseUrl$endpoint',
          (server) => server.throws(
            0,
            DioException(
              type: DioExceptionType.connectionError,
              requestOptions: RequestOptions(),
              message: 'Connection failed',
            ),
          ),
          queryParameters: {
            'start': '127.0,37.0',
            'goal': '127.5,37.5',
            'option': 'trafast',
          },
        );

        expect(
          () => dataSource.getDirections(
            startLat: 37.0,
            startLng: 127.0,
            endLat: 37.5,
            endLng: 127.5,
          ),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
