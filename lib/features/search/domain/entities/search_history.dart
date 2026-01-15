import 'package:equatable/equatable.dart';

class SearchHistory extends Equatable {
  final String keyword;
  final DateTime searchedAt;

  SearchHistory({required this.keyword, required this.searchedAt}) {
    if (keyword.trim().isEmpty) {
      throw ArgumentError('keyword cannot be empty or whitespace only');
    }
  }

  @override
  List<Object?> get props => [keyword, searchedAt];
}
