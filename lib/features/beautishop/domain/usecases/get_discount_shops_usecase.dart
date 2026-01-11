import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/core/usecase/usecase.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';

class GetDiscountShopsUseCase
    implements UseCase<Either<Failure, List<BeautyShop>>, NoParams> {
  final BeautyShopRepository _repository;

  GetDiscountShopsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BeautyShop>>> call(NoParams params) async {
    return _repository.getDiscountShops();
  }
}
