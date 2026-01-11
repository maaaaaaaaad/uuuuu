import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/core/usecase/usecase.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';

class GetNearbyShopsParams {
  final double latitude;
  final double longitude;
  final double? radiusKm;

  const GetNearbyShopsParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm,
  });
}

class GetNearbyShopsUseCase
    implements UseCase<Either<Failure, List<BeautyShop>>, GetNearbyShopsParams> {
  final BeautyShopRepository _repository;

  GetNearbyShopsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BeautyShop>>> call(
      GetNearbyShopsParams params) async {
    return _repository.getNearbyShops(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: params.radiusKm,
    );
  }
}
