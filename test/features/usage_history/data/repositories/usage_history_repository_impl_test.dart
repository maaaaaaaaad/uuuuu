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

    test('should return AuthFailure when data source throws 401 DioException',
        () async {
      when(() => mockDataSource.getMyUsageHistory()).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(),
          response: Response(
            data: {'code': 'INVALID_TOKEN'},
            statusCode: 401,
            requestOptions: RequestOptions(),
          ),
        ),
      );

      final result = await repository.getMyUsageHistory();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, '인증이 만료되었습니다. 다시 로그인해주세요');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('should return ServerFailure with fallback when response has no code',
        () async {
      when(() => mockDataSource.getMyUsageHistory()).thenThrow(
        DioException(requestOptions: RequestOptions()),
      );

      final result = await repository.getMyUsageHistory();

      result.fold(
        (failure) => expect(failure.message, '이용 내역을 불러올 수 없습니다'),
        (_) => fail('Expected Left'),
      );
    });
  });
}
