import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/search/domain/entities/search_history.dart';
import 'package:jellomark/features/search/domain/repositories/search_repository.dart';

class ManageSearchHistoryUseCase {
  final SearchRepository _repository;

  ManageSearchHistoryUseCase({required SearchRepository repository})
    : _repository = repository;

  Future<Either<Failure, void>> saveSearchHistory(String keyword) {
    return _repository.saveSearchHistory(keyword);
  }

  Future<Either<Failure, List<SearchHistory>>> getSearchHistory() {
    return _repository.getSearchHistory();
  }

  Future<Either<Failure, void>> deleteSearchHistory(String keyword) {
    return _repository.deleteSearchHistory(keyword);
  }

  Future<Either<Failure, void>> clearAllSearchHistory() {
    return _repository.clearAllSearchHistory();
  }
}
