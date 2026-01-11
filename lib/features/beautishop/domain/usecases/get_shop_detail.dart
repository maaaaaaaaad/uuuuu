import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';

class GetShopDetail {
  final BeautyShopRepository repository;

  GetShopDetail({required this.repository});

  Future<Either<Failure, ShopDetail>> call({required String shopId}) {
    return repository.getShopDetail(shopId);
  }
}
