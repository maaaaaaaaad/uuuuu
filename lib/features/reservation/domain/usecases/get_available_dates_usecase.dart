import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/repositories/reservation_repository.dart';

class GetAvailableDatesUseCase {
  final ReservationRepository repository;

  GetAvailableDatesUseCase({required this.repository});

  Future<Either<Failure, List<String>>> call(
      String shopId, String treatmentId, String yearMonth) {
    return repository.getAvailableDates(shopId, treatmentId, yearMonth);
  }
}
