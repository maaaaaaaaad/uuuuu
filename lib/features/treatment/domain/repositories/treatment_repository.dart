import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';

abstract class TreatmentRepository {
  Future<Either<Failure, List<ServiceMenu>>> getShopTreatments(String shopId);

  Future<Either<Failure, ServiceMenu>> getTreatmentById(String treatmentId);
}
