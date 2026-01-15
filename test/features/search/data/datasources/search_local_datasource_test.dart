import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/search/data/datasources/search_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SearchLocalDataSource dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dataSource = SearchLocalDataSourceImpl();
  });

  group('saveSearchHistory', () {
    test('should save keyword to SharedPreferences', () async {
      await dataSource.saveSearchHistory('강남 네일');

      final history = await dataSource.getSearchHistory();
      expect(history.length, equals(1));
      expect(history[0].keyword, equals('강남 네일'));
    });

    test('should move duplicate keyword to top of list', () async {
      await dataSource.saveSearchHistory('강남 네일');
      await dataSource.saveSearchHistory('홍대 헤어');
      await dataSource.saveSearchHistory('강남 네일');

      final history = await dataSource.getSearchHistory();
      expect(history.length, equals(2));
      expect(history[0].keyword, equals('강남 네일'));
      expect(history[1].keyword, equals('홍대 헤어'));
    });

    test('should limit history to 10 items', () async {
      for (var i = 1; i <= 12; i++) {
        await dataSource.saveSearchHistory('검색어 $i');
      }

      final history = await dataSource.getSearchHistory();
      expect(history.length, equals(10));
      expect(history[0].keyword, equals('검색어 12'));
      expect(history[9].keyword, equals('검색어 3'));
    });
  });

  group('getSearchHistory', () {
    test('should return empty list when no history', () async {
      final history = await dataSource.getSearchHistory();
      expect(history, isEmpty);
    });

    test('should return list ordered by most recent first', () async {
      await dataSource.saveSearchHistory('첫번째');
      await dataSource.saveSearchHistory('두번째');
      await dataSource.saveSearchHistory('세번째');

      final history = await dataSource.getSearchHistory();
      expect(history[0].keyword, equals('세번째'));
      expect(history[1].keyword, equals('두번째'));
      expect(history[2].keyword, equals('첫번째'));
    });
  });

  group('deleteSearchHistory', () {
    test('should delete specific keyword from history', () async {
      await dataSource.saveSearchHistory('강남 네일');
      await dataSource.saveSearchHistory('홍대 헤어');

      await dataSource.deleteSearchHistory('강남 네일');

      final history = await dataSource.getSearchHistory();
      expect(history.length, equals(1));
      expect(history[0].keyword, equals('홍대 헤어'));
    });

    test('should do nothing if keyword not found', () async {
      await dataSource.saveSearchHistory('강남 네일');

      await dataSource.deleteSearchHistory('존재하지않음');

      final history = await dataSource.getSearchHistory();
      expect(history.length, equals(1));
    });
  });

  group('clearAllSearchHistory', () {
    test('should remove all history', () async {
      await dataSource.saveSearchHistory('강남 네일');
      await dataSource.saveSearchHistory('홍대 헤어');

      await dataSource.clearAllSearchHistory();

      final history = await dataSource.getSearchHistory();
      expect(history, isEmpty);
    });
  });
}
