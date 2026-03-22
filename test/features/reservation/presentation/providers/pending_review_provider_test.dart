import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_pending_review_reservations_usecase.dart';
import 'package:jellomark/features/reservation/presentation/providers/pending_review_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPendingReviewReservationsUseCase extends Mock
    implements GetPendingReviewReservationsUseCase {}

void main() {
  late MockGetPendingReviewReservationsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetPendingReviewReservationsUseCase();
  });

  final tReservation1 = Reservation(
    id: 'res-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    reservationDate: '2025-06-15',
    startTime: '14:00',
    endTime: '15:00',
    status: ReservationStatus.completed,
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  final tReservation2 = Reservation(
    id: 'res-2',
    shopId: 'shop-2',
    memberId: 'member-1',
    treatmentId: 'treatment-2',
    shopName: '뷰티샵',
    treatmentName: '매니큐어',
    reservationDate: '2025-06-16',
    startTime: '10:00',
    endTime: '11:00',
    status: ReservationStatus.completed,
    createdAt: DateTime(2025, 6, 11),
    updatedAt: DateTime(2025, 6, 11),
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getPendingReviewReservationsUseCaseProvider
            .overrideWithValue(mockUseCase),
      ],
    );
  }

  group('PendingReviewNotifier', () {
    test('should load pending reviews successfully', () async {
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([tReservation1, tReservation2]));

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(pendingReviewNotifierProvider.notifier)
          .loadPendingReviews();

      final state = container.read(pendingReviewNotifierProvider);
      expect(state.reservations.length, 2);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should handle load failure', () async {
      when(() => mockUseCase())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(pendingReviewNotifierProvider.notifier)
          .loadPendingReviews();

      final state = container.read(pendingReviewNotifierProvider);
      expect(state.reservations, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, '서버 오류');
    });

    test('should remove reservation by reservationId', () async {
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([tReservation1, tReservation2]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(pendingReviewNotifierProvider.notifier);
      await notifier.loadPendingReviews();
      notifier.removeByReservationId(tReservation1.id);

      final state = container.read(pendingReviewNotifierProvider);
      expect(state.reservations.length, 1);
      expect(state.reservations.first.id, tReservation2.id);
    });

    test('should refresh by reloading', () async {
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([tReservation1]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(pendingReviewNotifierProvider.notifier);
      await notifier.refresh();

      final state = container.read(pendingReviewNotifierProvider);
      expect(state.reservations.length, 1);
      verify(() => mockUseCase()).called(2);
    });
  });

  group('pendingReviewCountProvider', () {
    test('should return count of pending reviews', () async {
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([tReservation1, tReservation2]));

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(pendingReviewNotifierProvider.notifier)
          .loadPendingReviews();

      final count = container.read(pendingReviewCountProvider);
      expect(count, 2);
    });

    test('should return 0 when no pending reviews', () async {
      when(() => mockUseCase()).thenAnswer((_) async => const Right([]));

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(pendingReviewNotifierProvider.notifier)
          .loadPendingReviews();

      final count = container.read(pendingReviewCountProvider);
      expect(count, 0);
    });
  });
}
