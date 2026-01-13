import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/treatment/domain/repositories/treatment_repository.dart';

class GetTreatmentDetailUseCase {
  final TreatmentRepository repository;

  GetTreatmentDetailUseCase({required this.repository});

  Future<Either<Failure, ServiceMenu>> call({required String treatmentId}) {
    return repository.getTreatmentById(treatmentId);
  }
}
