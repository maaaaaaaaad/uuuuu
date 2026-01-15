import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/search/domain/entities/search_history.dart';
import 'package:jellomark/features/search/domain/repositories/search_repository.dart';
import 'package:jellomark/features/search/domain/usecases/manage_search_history_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late ManageSearchHistoryUseCase useCase;
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
    useCase = ManageSearchHistoryUseCase(repository: mockRepository);
  });

  group('saveSearchHistory', () {
    test('should call repository saveSearchHistory with keyword', () async {
      when(
        () => mockRepository.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await useCase.saveSearchHistory('강남 네일');

      verify(() => mockRepository.saveSearchHistory('강남 네일')).called(1);
    });

    test('should return Right(void) on success', () async {
      when(
        () => mockRepository.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase.saveSearchHistory('강남 네일');

      expect(result, equals(const Right(null)));
    });

    test('should return Left(Failure) on error', () async {
      when(
        () => mockRepository.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Left(CacheFailure('저장 실패')));

      final result = await useCase.saveSearchHistory('강남 네일');

      expect(result.isLeft(), isTrue);
    });
  });

  group('getSearchHistory', () {
    test('should call repository getSearchHistory', () async {
      when(
        () => mockRepository.getSearchHistory(),
      ).thenAnswer((_) async => const Right([]));

      await useCase.getSearchHistory();

      verify(() => mockRepository.getSearchHistory()).called(1);
    });

    test('should return list of SearchHistory on success', () async {
      final historyList = [
        SearchHistory(
          keyword: '강남 네일',
          searchedAt: DateTime(2024, 1, 15, 10, 30),
        ),
        SearchHistory(
          keyword: '홍대 헤어',
          searchedAt: DateTime(2024, 1, 15, 9, 30),
        ),
      ];
      when(
        () => mockRepository.getSearchHistory(),
      ).thenAnswer((_) async => Right(historyList));

      final result = await useCase.getSearchHistory();

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Expected Right but got Left'), (list) {
        expect(list.length, equals(2));
        expect(list[0].keyword, equals('강남 네일'));
        expect(list[1].keyword, equals('홍대 헤어'));
      });
    });

    test('should return Left(Failure) on error', () async {
      when(
        () => mockRepository.getSearchHistory(),
      ).thenAnswer((_) async => const Left(CacheFailure('조회 실패')));

      final result = await useCase.getSearchHistory();

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteSearchHistory', () {
    test('should call repository deleteSearchHistory with keyword', () async {
      when(
        () => mockRepository.deleteSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await useCase.deleteSearchHistory('강남 네일');

      verify(() => mockRepository.deleteSearchHistory('강남 네일')).called(1);
    });

    test('should return Right(void) on success', () async {
      when(
        () => mockRepository.deleteSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase.deleteSearchHistory('강남 네일');

      expect(result, equals(const Right(null)));
    });
  });

  group('clearAllSearchHistory', () {
    test('should call repository clearAllSearchHistory', () async {
      when(
        () => mockRepository.clearAllSearchHistory(),
      ).thenAnswer((_) async => const Right(null));

      await useCase.clearAllSearchHistory();

      verify(() => mockRepository.clearAllSearchHistory()).called(1);
    });

    test('should return Right(void) on success', () async {
      when(
        () => mockRepository.clearAllSearchHistory(),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase.clearAllSearchHistory();

      expect(result, equals(const Right(null)));
    });
  });
}
