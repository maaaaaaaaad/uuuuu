import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/repositories/reservation_repository.dart';

class CancelReservationUseCase {
  final ReservationRepository repository;

  CancelReservationUseCase({required this.repository});

  Future<Either<Failure, Reservation>> call(String reservationId) {
    return repository.cancelReservation(reservationId);
  }
}
