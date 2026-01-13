import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/treatment/domain/repositories/treatment_repository.dart';

class GetShopTreatmentsUseCase {
  final TreatmentRepository repository;

  GetShopTreatmentsUseCase({required this.repository});

  Future<Either<Failure, List<ServiceMenu>>> call({required String shopId}) {
    return repository.getShopTreatments(shopId);
  }
}
