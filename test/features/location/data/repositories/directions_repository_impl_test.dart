import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/data/datasources/directions_remote_data_source.dart';
import 'package:jellomark/features/location/data/models/directions_response_model.dart';
import 'package:jellomark/features/location/data/repositories/directions_repository_impl.dart';
import 'package:jellomark/features/location/domain/entities/route.dart';
import 'package:jellomark/features/location/domain/repositories/directions_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDirectionsRemoteDataSource extends Mock
    implements DirectionsRemoteDataSource {}

void main() {
  late DirectionsRepository repository;
  late MockDirectionsRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectionsRemoteDataSource();
    repository = DirectionsRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final successResponse = DirectionsResponseModel(
    code: 0,
    message: 'success',
    coordinates: const [
      LatLng(latitude: 37.456, longitude: 127.123),
      LatLng(latitude: 37.457, longitude: 127.124),
    ],
    distanceInMeters: 1234,
    durationInMillis: 600000,
  );

  final errorResponse = DirectionsResponseModel(
    code: 1,
    message: 'Route not found',
    coordinates: null,
    distanceInMeters: null,
    durationInMillis: null,
  );

  group('DirectionsRepositoryImpl', () {
    group('getRoute', () {
      test('returns Route on success', () async {
        when(
          () => mockDataSource.getDirections(
            startLat: any(named: 'startLat'),
            startLng: any(named: 'startLng'),
            endLat: any(named: 'endLat'),
            endLng: any(named: 'endLng'),
          ),
        ).thenAnswer((_) async => successResponse);

        final result = await repository.getRoute(
          startLat: 37.0,
          startLng: 127.0,
          endLat: 37.5,
          endLng: 127.5,
        );

        expect(result, isA<Right<Failure, Route>>());
        final route = (result as Right).value as Route;
        expect(route.coordinates.length, equals(2));
        expect(route.distanceInMeters, equals(1234));
        expect(route.durationInMillis, equals(600000));
      });

      test('calls dataSource with correct parameters', () async {
        when(
          () => mockDataSource.getDirections(
            startLat: any(named: 'startLat'),
            startLng: any(named: 'startLng'),
            endLat: any(named: 'endLat'),
            endLng: any(named: 'endLng'),
          ),
        ).thenAnswer((_) async => successResponse);

        await repository.getRoute(
          startLat: 37.123,
          startLng: 127.456,
          endLat: 38.789,
          endLng: 128.012,
        );

        verify(
          () => mockDataSource.getDirections(
            startLat: 37.123,
            startLng: 127.456,
            endLat: 38.789,
            endLng: 128.012,
          ),
        ).called(1);
      });

      test('returns ServerFailure when API returns error code', () async {
        when(
          () => mockDataSource.getDirections(
            startLat: any(named: 'startLat'),
            startLng: any(named: 'startLng'),
            endLat: any(named: 'endLat'),
            endLng: any(named: 'endLng'),
          ),
        ).thenAnswer((_) async => errorResponse);

        final result = await repository.getRoute(
          startLat: 37.0,
          startLng: 127.0,
          endLat: 37.5,
          endLng: 127.5,
        );

        expect(result, isA<Left<Failure, Route>>());
        final failure = (result as Left).value as ServerFailure;
        expect(failure.message, contains('Route not found'));
      });

      test('returns ServerFailure on DioException with response', () async {
        when(
          () => mockDataSource.getDirections(
            startLat: any(named: 'startLat'),
            startLng: any(named: 'startLng'),
            endLat: any(named: 'endLat'),
            endLng: any(named: 'endLng'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 500,
              data: {'error': 'Internal Server Error'},
            ),
          ),
        );

        final result = await repository.getRoute(
          startLat: 37.0,
          startLng: 127.0,
          endLat: 37.5,
          endLng: 127.5,
        );

        expect(result, isA<Left<Failure, Route>>());
        final failure = (result as Left).value as ServerFailure;
        expect(failure.message, contains('Internal Server Error'));
      });

      test('returns NetworkFailure on connection error', () async {
        when(
          () => mockDataSource.getDirections(
            startLat: any(named: 'startLat'),
            startLng: any(named: 'startLng'),
            endLat: any(named: 'endLat'),
            endLng: any(named: 'endLng'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(),
            message: 'Connection failed',
          ),
        );

        final result = await repository.getRoute(
          startLat: 37.0,
          startLng: 127.0,
          endLat: 37.5,
          endLng: 127.5,
        );

        expect(result, isA<Left<Failure, Route>>());
        expect((result as Left).value, isA<NetworkFailure>());
      });

      test('returns NetworkFailure on timeout', () async {
        when(
          () => mockDataSource.getDirections(
            startLat: any(named: 'startLat'),
            startLng: any(named: 'startLng'),
            endLat: any(named: 'endLat'),
            endLng: any(named: 'endLng'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.getRoute(
          startLat: 37.0,
          startLng: 127.0,
          endLat: 37.5,
          endLng: 127.5,
        );

        expect(result, isA<Left<Failure, Route>>());
        expect((result as Left).value, isA<NetworkFailure>());
      });
    });
  });
}
