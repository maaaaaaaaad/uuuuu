import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/search/domain/entities/search_history.dart';

abstract class SearchRepository {
  Future<Either<Failure, void>> saveSearchHistory(String keyword);

  Future<Either<Failure, List<SearchHistory>>> getSearchHistory();

  Future<Either<Failure, void>> deleteSearchHistory(String keyword);

  Future<Either<Failure, void>> clearAllSearchHistory();
}
