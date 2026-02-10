import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/usage_history/data/datasources/usage_history_remote_datasource.dart';
import 'package:jellomark/features/usage_history/data/models/usage_history_model.dart';
import 'package:jellomark/features/usage_history/data/repositories/usage_history_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockUsageHistoryRemoteDataSource extends Mock
    implements UsageHistoryRemoteDataSource {}

void main() {
  late MockUsageHistoryRemoteDataSource mockDataSource;
  late UsageHistoryRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockUsageHistoryRemoteDataSource();
    repository = UsageHistoryRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final tModel = UsageHistoryModel(
    id: 'uh-1',
    memberId: 'member-1',
    shopId: 'shop-1',
    reservationId: 'reservation-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    completedAt: DateTime.utc(2026, 1, 15, 14, 0),
    createdAt: DateTime.utc(2026, 1, 15, 14, 0),
  );

  group('getMyUsageHistory', () {
    test('should return list of UsageHistory when data source call is successful',
        () async {
      when(() => mockDataSource.getMyUsageHistory())
          .thenAnswer((_) async => [tModel]);

      final result = await repository.getMyUsageHistory();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (histories) {
          expect(histories.length, 1);
          expect(histories.first.id, 'uh-1');
          expect(histories.first.shopName, '젤로네일');
        },
      );
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() => mockDataSource.getMyUsageHistory()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(
            data: {'message': '인증 오류'},
            statusCode: 401,
            requestOptions: RequestOptions(),
          ),
        ),
      );

      final result = await repository.getMyUsageHistory();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, '인증 오류');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('should return default error message when response has no message',
        () async {
      when(() => mockDataSource.getMyUsageHistory()).thenThrow(
        DioException(requestOptions: RequestOptions()),
      );

      final result = await repository.getMyUsageHistory();

      result.fold(
        (failure) => expect(failure.message, '서버 오류가 발생했습니다'),
        (_) => fail('Expected Left'),
      );
    });
  });
}
