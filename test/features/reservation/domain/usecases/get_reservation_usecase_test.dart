import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_reservation_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late GetReservationUseCase useCase;
  late MockReservationRepository mockRepository;

  setUp(() {
    mockRepository = MockReservationRepository();
    useCase = GetReservationUseCase(repository: mockRepository);
  });

  final tReservation = Reservation(
    id: 'res-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    reservationDate: '2025-06-15',
    startTime: '14:00',
    endTime: '15:00',
    status: ReservationStatus.pending,
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  const tReservationId = 'res-1';

  test('should return Reservation when repository call is successful', () async {
    when(() => mockRepository.getReservation(tReservationId))
        .thenAnswer((_) async => Right(tReservation));

    final result = await useCase(tReservationId);

    expect(result, Right(tReservation));
    verify(() => mockRepository.getReservation(tReservationId)).called(1);
  });

  test('should return Failure when repository fails', () async {
    when(() => mockRepository.getReservation(tReservationId))
        .thenAnswer((_) async => const Left(ServerFailure('Error')));

    final result = await useCase(tReservationId);

    expect(result, isA<Left<Failure, Reservation>>());
  });
}
