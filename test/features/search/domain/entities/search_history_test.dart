import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/search/domain/entities/search_history.dart';

void main() {
  group('SearchHistory', () {
    test('creates instance with keyword and timestamp', () {
      final now = DateTime.now();
      final history = SearchHistory(keyword: '강남 네일', searchedAt: now);

      expect(history.keyword, equals('강남 네일'));
      expect(history.searchedAt, equals(now));
    });

    test('two instances with same values are equal', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final history1 = SearchHistory(keyword: '홍대 헤어', searchedAt: timestamp);
      final history2 = SearchHistory(keyword: '홍대 헤어', searchedAt: timestamp);

      expect(history1, equals(history2));
    });

    test('two instances with different keywords are not equal', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final history1 = SearchHistory(keyword: '강남 네일', searchedAt: timestamp);
      final history2 = SearchHistory(keyword: '홍대 헤어', searchedAt: timestamp);

      expect(history1, isNot(equals(history2)));
    });

    test('two instances with different timestamps are not equal', () {
      final history1 = SearchHistory(
        keyword: '강남 네일',
        searchedAt: DateTime(2024, 1, 15, 10, 30),
      );
      final history2 = SearchHistory(
        keyword: '강남 네일',
        searchedAt: DateTime(2024, 1, 15, 11, 30),
      );

      expect(history1, isNot(equals(history2)));
    });

    test('keyword cannot be empty', () {
      expect(
        () => SearchHistory(keyword: '', searchedAt: DateTime.now()),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('keyword cannot be whitespace only', () {
      expect(
        () => SearchHistory(keyword: '   ', searchedAt: DateTime.now()),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
