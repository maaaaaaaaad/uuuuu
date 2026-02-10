import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';
import 'package:jellomark/features/reservation/domain/repositories/reservation_repository.dart';

class GetAvailableSlotsUseCase {
  final ReservationRepository repository;

  GetAvailableSlotsUseCase({required this.repository});

  Future<Either<Failure, AvailableSlotsResult>> call(
      String shopId, String treatmentId, String date) {
    return repository.getAvailableSlots(shopId, treatmentId, date);
  }
}
