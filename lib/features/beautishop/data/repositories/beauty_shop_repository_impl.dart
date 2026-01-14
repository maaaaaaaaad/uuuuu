import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/data/datasources/beauty_shop_remote_datasource.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_shop_reviews.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';

class BeautyShopRepositoryImpl implements BeautyShopRepository {
  final BeautyShopRemoteDataSource _remoteDataSource;

  BeautyShopRepositoryImpl({
    required BeautyShopRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, PagedBeautyShops>> getBeautyShops({
    required int page,
    required int size,
    String? sortBy,
    String? sortOrder,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? minRating,
  }) async {
    try {
      final pagedModel = await _remoteDataSource.getBeautyShops(
        page: page,
        size: size,
        sortBy: sortBy,
        sortOrder: sortOrder,
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        minRating: minRating,
      );

      return Right(
        PagedBeautyShops(
          items: pagedModel.items,
          hasNext: pagedModel.hasNext,
          totalElements: pagedModel.totalElements,
        ),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, BeautyShop>> getBeautyShopById(String shopId) async {
    try {
      final shopModel = await _remoteDataSource.getBeautyShopById(shopId);
      return Right(shopModel);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<BeautyShop>>> getNearbyShops({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    try {
      final pagedModel = await _remoteDataSource.getBeautyShops(
        page: 0,
        size: 10,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(pagedModel.items);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<BeautyShop>>> getRecommendedShops() async {
    try {
      final pagedModel = await _remoteDataSource.getBeautyShops(
        page: 0,
        size: 10,
        sortBy: 'RATING',
        sortOrder: 'DESC',
      );
      return Right(pagedModel.items);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<BeautyShop>>> getDiscountShops() async {
    try {
      final pagedModel = await _remoteDataSource.getBeautyShops(
        page: 0,
        size: 10,
      );
      return Right(pagedModel.items);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<BeautyShop>>> getNewShops() async {
    try {
      final pagedModel = await _remoteDataSource.getBeautyShops(
        page: 0,
        size: 10,
        sortBy: 'CREATED_AT',
        sortOrder: 'DESC',
      );
      return Right(pagedModel.items);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ShopDetail>> getShopDetail(String shopId) async {
    return const Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, List<ServiceMenu>>> getShopServices(
    String shopId,
  ) async {
    return const Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, PagedShopReviews>> getShopReviews(
    String shopId, {
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    try {
      final pagedModel = await _remoteDataSource.getShopReviews(
        shopId,
        page: page,
        size: size,
        sort: sort,
      );
      return Right(pagedModel);
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
