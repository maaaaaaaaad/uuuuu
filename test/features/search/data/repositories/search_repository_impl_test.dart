import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/search/data/datasources/search_local_datasource.dart';
import 'package:jellomark/features/search/data/repositories/search_repository_impl.dart';
import 'package:jellomark/features/search/domain/entities/search_history.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchLocalDataSource extends Mock implements SearchLocalDataSource {}

void main() {
  late SearchRepositoryImpl repository;
  late MockSearchLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSearchLocalDataSource();
    repository = SearchRepositoryImpl(localDataSource: mockDataSource);
  });

  group('saveSearchHistory', () {
    test('should call localDataSource saveSearchHistory', () async {
      when(
        () => mockDataSource.saveSearchHistory(any()),
      ).thenAnswer((_) async {});

      await repository.saveSearchHistory('강남 네일');

      verify(() => mockDataSource.saveSearchHistory('강남 네일')).called(1);
    });

    test('should return Right(void) on success', () async {
      when(
        () => mockDataSource.saveSearchHistory(any()),
      ).thenAnswer((_) async {});

      final result = await repository.saveSearchHistory('강남 네일');

      expect(result, equals(const Right(null)));
    });

    test('should return Left(CacheFailure) on exception', () async {
      when(
        () => mockDataSource.saveSearchHistory(any()),
      ).thenThrow(Exception('저장 실패'));

      final result = await repository.saveSearchHistory('강남 네일');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getSearchHistory', () {
    test('should call localDataSource getSearchHistory', () async {
      when(() => mockDataSource.getSearchHistory()).thenAnswer((_) async => []);

      await repository.getSearchHistory();

      verify(() => mockDataSource.getSearchHistory()).called(1);
    });

    test('should return Right(List<SearchHistory>) on success', () async {
      final historyList = [
        SearchHistory(keyword: '강남 네일', searchedAt: DateTime(2024, 1, 15)),
      ];
      when(
        () => mockDataSource.getSearchHistory(),
      ).thenAnswer((_) async => historyList);

      final result = await repository.getSearchHistory();

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Expected Right but got Left'), (list) {
        expect(list.length, equals(1));
        expect(list[0].keyword, equals('강남 네일'));
      });
    });

    test('should return Left(CacheFailure) on exception', () async {
      when(
        () => mockDataSource.getSearchHistory(),
      ).thenThrow(Exception('조회 실패'));

      final result = await repository.getSearchHistory();

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteSearchHistory', () {
    test('should call localDataSource deleteSearchHistory', () async {
      when(
        () => mockDataSource.deleteSearchHistory(any()),
      ).thenAnswer((_) async {});

      await repository.deleteSearchHistory('강남 네일');

      verify(() => mockDataSource.deleteSearchHistory('강남 네일')).called(1);
    });

    test('should return Right(void) on success', () async {
      when(
        () => mockDataSource.deleteSearchHistory(any()),
      ).thenAnswer((_) async {});

      final result = await repository.deleteSearchHistory('강남 네일');

      expect(result, equals(const Right(null)));
    });
  });

  group('clearAllSearchHistory', () {
    test('should call localDataSource clearAllSearchHistory', () async {
      when(
        () => mockDataSource.clearAllSearchHistory(),
      ).thenAnswer((_) async {});

      await repository.clearAllSearchHistory();

      verify(() => mockDataSource.clearAllSearchHistory()).called(1);
    });

    test('should return Right(void) on success', () async {
      when(
        () => mockDataSource.clearAllSearchHistory(),
      ).thenAnswer((_) async {});

      final result = await repository.clearAllSearchHistory();

      expect(result, equals(const Right(null)));
    });
  });
}
