import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/recent_shops/data/datasources/recent_shops_local_datasource.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/repositories/recent_shops_repository.dart';

class RecentShopsRepositoryImpl implements RecentShopsRepository {
  final RecentShopsLocalDataSource _localDataSource;

  RecentShopsRepositoryImpl({required RecentShopsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, void>> addRecentShop(RecentShop shop) async {
    try {
      await _localDataSource.addRecentShop(shop);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecentShop>>> getRecentShops() async {
    try {
      final shops = await _localDataSource.getRecentShops();
      return Right(shops);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearRecentShops() async {
    try {
      await _localDataSource.clearRecentShops();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
