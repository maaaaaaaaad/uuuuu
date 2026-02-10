import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';

abstract class ReservationRepository {
  Future<Either<Failure, Reservation>> createReservation(
      CreateReservationParams params);
  Future<Either<Failure, List<Reservation>>> getMyReservations();
  Future<Either<Failure, Reservation>> cancelReservation(
      String reservationId);
  Future<Either<Failure, List<String>>> getAvailableDates(
      String shopId, String treatmentId, String yearMonth);
  Future<Either<Failure, AvailableSlotsResult>> getAvailableSlots(
      String shopId, String treatmentId, String date);
}
