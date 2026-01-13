import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/category/data/datasources/category_remote_datasource.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:jellomark/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl({required CategoryRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      return Right(categories);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      return (e.response?.data as Map)['error']?.toString() ?? '알 수 없는 오류';
    }
    return e.message ?? '알 수 없는 오류';
  }
}
