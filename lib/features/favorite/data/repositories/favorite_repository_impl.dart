import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/core/network/api_error_handler.dart';
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
      return Left(
        ApiErrorHandler.fromDioException(e, fallback: '즐겨찾기 추가에 실패했습니다'),
      );
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
      return Left(
        ApiErrorHandler.fromDioException(e, fallback: '즐겨찾기 해제에 실패했습니다'),
      );
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
      return Left(
        ApiErrorHandler.fromDioException(e, fallback: '즐겨찾기 목록을 불러올 수 없습니다'),
      );
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
      return Left(
        ApiErrorHandler.fromDioException(e, fallback: '즐겨찾기 확인에 실패했습니다'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
