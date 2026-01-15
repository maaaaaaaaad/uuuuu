import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/search/data/datasources/search_local_datasource.dart';
import 'package:jellomark/features/search/domain/entities/search_history.dart';
import 'package:jellomark/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchLocalDataSource _localDataSource;

  SearchRepositoryImpl({required SearchLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, void>> saveSearchHistory(String keyword) async {
    try {
      await _localDataSource.saveSearchHistory(keyword);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchHistory>>> getSearchHistory() async {
    try {
      final history = await _localDataSource.getSearchHistory();
      return Right(history);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSearchHistory(String keyword) async {
    try {
      await _localDataSource.deleteSearchHistory(keyword);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllSearchHistory() async {
    try {
      await _localDataSource.clearAllSearchHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
