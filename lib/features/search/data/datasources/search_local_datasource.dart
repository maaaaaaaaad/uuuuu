import 'dart:convert';

import 'package:jellomark/features/search/domain/entities/search_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SearchLocalDataSource {
  Future<void> saveSearchHistory(String keyword);

  Future<List<SearchHistory>> getSearchHistory();

  Future<void> deleteSearchHistory(String keyword);

  Future<void> clearAllSearchHistory();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryCount = 10;

  @override
  Future<void> saveSearchHistory(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = await _getHistoryList(prefs);

    historyList.removeWhere((item) => item['keyword'] == keyword);

    historyList.insert(0, {
      'keyword': keyword,
      'searchedAt': DateTime.now().toIso8601String(),
    });

    if (historyList.length > _maxHistoryCount) {
      historyList.removeRange(_maxHistoryCount, historyList.length);
    }

    await prefs.setString(_searchHistoryKey, jsonEncode(historyList));
  }

  @override
  Future<List<SearchHistory>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = await _getHistoryList(prefs);

    return historyList
        .map(
          (item) => SearchHistory(
            keyword: item['keyword'] as String,
            searchedAt: DateTime.parse(item['searchedAt'] as String),
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteSearchHistory(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = await _getHistoryList(prefs);

    historyList.removeWhere((item) => item['keyword'] == keyword);

    await prefs.setString(_searchHistoryKey, jsonEncode(historyList));
  }

  @override
  Future<void> clearAllSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }

  Future<List<Map<String, dynamic>>> _getHistoryList(
    SharedPreferences prefs,
  ) async {
    final jsonString = prefs.getString(_searchHistoryKey);
    if (jsonString == null) {
      return [];
    }

    final decoded = jsonDecode(jsonString) as List;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }
}
