import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:jellomark/features/favorite/domain/entities/favorite_shop.dart';
import 'package:jellomark/features/favorite/domain/entities/paged_favorites.dart';
import 'package:jellomark/features/favorite/domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource _remoteDataSource;

  FavoriteRepositoryImpl({required FavoriteRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, FavoriteShop>> addFavorite(String shopId) async {
    try {
      final result = await _remoteDataSource.addFavorite(shopId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String shopId) async {
    try {
      await _remoteDataSource.removeFavorite(shopId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PagedFavorites>> getFavorites({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final result = await _remoteDataSource.getFavorites(page: page, size: size);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkFavorite(String shopId) async {
    try {
      final result = await _remoteDataSource.checkFavorite(shopId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      return data['message'] as String? ?? '서버 오류가 발생했습니다';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return '네트워크 연결 시간이 초과되었습니다';
      case DioExceptionType.connectionError:
        return '네트워크 연결에 실패했습니다';
      default:
        return '서버 오류가 발생했습니다';
    }
  }
}
