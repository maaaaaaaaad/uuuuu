import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/notification/data/datasources/device_token_remote_datasource.dart';
import 'package:jellomark/features/notification/data/repositories/device_token_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceTokenRemoteDataSource extends Mock
    implements DeviceTokenRemoteDataSource {}

void main() {
  late DeviceTokenRepositoryImpl repository;
  late MockDeviceTokenRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDeviceTokenRemoteDataSource();
    repository = DeviceTokenRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('registerToken', () {
    test('should return Right(null) on success', () async {
      when(() => mockDataSource.registerToken('token', 'IOS'))
          .thenAnswer((_) async {});

      final result = await repository.registerToken('token', 'IOS');

      expect(result, const Right(null));
      verify(() => mockDataSource.registerToken('token', 'IOS')).called(1);
    });

    test('should return Left(ServerFailure) on DioException', () async {
      when(() => mockDataSource.registerToken('token', 'IOS')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/device-tokens'),
          message: '등록 실패',
        ),
      );

      final result = await repository.registerToken('token', 'IOS');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('unregisterToken', () {
    test('should return Right(null) on success', () async {
      when(() => mockDataSource.unregisterToken('token'))
          .thenAnswer((_) async {});

      final result = await repository.unregisterToken('token');

      expect(result, const Right(null));
      verify(() => mockDataSource.unregisterToken('token')).called(1);
    });

    test('should return Left(ServerFailure) on DioException', () async {
      when(() => mockDataSource.unregisterToken('token')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/device-tokens/token'),
          message: '삭제 실패',
        ),
      );

      final result = await repository.unregisterToken('token');

      expect(result.isLeft(), true);
    });
  });
}
