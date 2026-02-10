import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/repositories/reservation_repository.dart';

class CreateReservationUseCase {
  final ReservationRepository repository;

  CreateReservationUseCase({required this.repository});

  Future<Either<Failure, Reservation>> call(CreateReservationParams params) {
    return repository.createReservation(params);
  }
}
