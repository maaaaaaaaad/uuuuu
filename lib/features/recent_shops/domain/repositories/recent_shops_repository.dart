import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';

abstract class RecentShopsRepository {
  Future<Either<Failure, void>> addRecentShop(RecentShop shop);

  Future<Either<Failure, List<RecentShop>>> getRecentShops();

  Future<Either<Failure, void>> clearRecentShops();
}
