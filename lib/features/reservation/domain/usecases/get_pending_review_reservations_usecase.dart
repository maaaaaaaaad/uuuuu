import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/repositories/reservation_repository.dart';

class GetPendingReviewReservationsUseCase {
  final ReservationRepository repository;

  GetPendingReviewReservationsUseCase({required this.repository});

  Future<Either<Failure, List<Reservation>>> call() {
    return repository.getPendingReviewReservations();
  }
}
