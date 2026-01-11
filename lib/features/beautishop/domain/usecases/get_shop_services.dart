import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';

class GetShopServices {
  final BeautyShopRepository repository;

  GetShopServices({required this.repository});

  Future<Either<Failure, List<ServiceMenu>>> call({required String shopId}) {
    return repository.getShopServices(shopId);
  }
}
