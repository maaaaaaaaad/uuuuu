import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/data/datasources/reservation_remote_datasource.dart';
import 'package:jellomark/features/reservation/data/models/create_reservation_request.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/repositories/reservation_repository.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  ReservationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Reservation>> createReservation(
      CreateReservationParams params) async {
    try {
      final request = CreateReservationRequest.fromParams(params);
      final result = await remoteDataSource.createReservation(request);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<Reservation>>> getMyReservations() async {
    try {
      final result = await remoteDataSource.getMyReservations();
      return Right(result.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> cancelReservation(
      String reservationId) async {
    try {
      final result = await remoteDataSource.cancelReservation(reservationId);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableDates(
      String shopId, String treatmentId, String yearMonth) async {
    try {
      final result = await remoteDataSource.getAvailableDates(
          shopId, treatmentId, yearMonth);
      return Right(result.availableDates);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, AvailableSlotsResult>> getAvailableSlots(
      String shopId, String treatmentId, String date) async {
    try {
      final result =
          await remoteDataSource.getAvailableSlots(shopId, treatmentId, date);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }
}
