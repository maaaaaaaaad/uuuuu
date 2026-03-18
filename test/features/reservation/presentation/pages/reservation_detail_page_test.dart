import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/domain/usecases/cancel_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_my_reservations_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_reservation_usecase.dart';
import 'package:jellomark/features/reservation/presentation/pages/reservation_detail_page.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_detail_provider.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_status_badge.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMyReservationsUseCase extends Mock
    implements GetMyReservationsUseCase {}

class MockCancelReservationUseCase extends Mock
    implements CancelReservationUseCase {}

class MockGetReservationUseCase extends Mock
    implements GetReservationUseCase {}

void main() {
  late MockGetMyReservationsUseCase mockGetUseCase;
  late MockCancelReservationUseCase mockCancelUseCase;
  late MockGetReservationUseCase mockGetReservationUseCase;

  setUp(() {
    mockGetUseCase = MockGetMyReservationsUseCase();
    mockCancelUseCase = MockCancelReservationUseCase();
    mockGetReservationUseCase = MockGetReservationUseCase();
  });

  final tReservation = Reservation(
    id: 'res-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    reservationDate: '2025-06-15',
    startTime: '14:00',
    endTime: '15:00',
    status: ReservationStatus.pending,
    memo: '첫 방문입니다',
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  final tRejectedReservation = Reservation(
    id: 'res-2',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    reservationDate: '2025-06-15',
    startTime: '14:00',
    endTime: '15:00',
    status: ReservationStatus.rejected,
    rejectionReason: '해당 시간에 예약이 불가합니다',
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  final tCompletedReservation = Reservation(
    id: 'res-3',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    reservationDate: '2025-06-15',
    startTime: '14:00',
    endTime: '15:00',
    status: ReservationStatus.completed,
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  Future<void> pumpDetailPage(
    WidgetTester tester,
    String reservationId,
    List<Reservation> cachedReservations,
  ) async {
    when(() => mockGetUseCase())
        .thenAnswer((_) async => Right(cachedReservations));

    final container = ProviderContainer(
      overrides: [
        getMyReservationsUseCaseProvider.overrideWithValue(mockGetUseCase),
        cancelReservationUseCaseProvider
            .overrideWithValue(mockCancelUseCase),
        getReservationUseCaseProvider
            .overrideWithValue(mockGetReservationUseCase),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(myReservationsNotifierProvider.notifier)
        .loadReservations();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ReservationDetailPage(reservationId: reservationId),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> pumpDetailPageFromApi(
    WidgetTester tester,
    String reservationId,
    Reservation reservation,
  ) async {
    when(() => mockGetUseCase())
        .thenAnswer((_) async => const Right([]));
    when(() => mockGetReservationUseCase(reservationId))
        .thenAnswer((_) async => Right(reservation));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getMyReservationsUseCaseProvider.overrideWithValue(mockGetUseCase),
          cancelReservationUseCaseProvider
              .overrideWithValue(mockCancelUseCase),
          getReservationUseCaseProvider
              .overrideWithValue(mockGetReservationUseCase),
        ],
        child: MaterialApp(
          home: ReservationDetailPage(reservationId: reservationId),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('ReservationDetailPage', () {
    testWidgets('should display app bar with title', (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.text('예약 상세'), findsOneWidget);
    });

    testWidgets('should display treatment name', (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('should display shop name', (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.text('젤로네일'), findsOneWidget);
    });

    testWidgets('should display date and time', (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.text('2025-06-15'), findsOneWidget);
      expect(find.text('14:00 - 15:00'), findsOneWidget);
    });

    testWidgets('should display status badge', (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.byType(ReservationStatusBadge), findsOneWidget);
    });

    testWidgets('should display memo when present', (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.text('메모'), findsOneWidget);
      expect(find.text('첫 방문입니다'), findsOneWidget);
    });

    testWidgets('should display cancel button for pending reservation',
        (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.text('예약 취소'), findsOneWidget);
    });

    testWidgets('should not display cancel button for rejected reservation',
        (tester) async {
      await pumpDetailPage(tester, 'res-2', [tRejectedReservation]);

      expect(find.text('예약 취소'), findsNothing);
    });

    testWidgets('should display rejection reason when present',
        (tester) async {
      await pumpDetailPage(tester, 'res-2', [tRejectedReservation]);

      expect(find.text('거절 사유'), findsOneWidget);
      expect(find.text('해당 시간에 예약이 불가합니다'), findsOneWidget);
    });

    testWidgets('should display price', (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.text('30,000원'), findsOneWidget);
    });

    testWidgets('should display duration', (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.text('60분'), findsOneWidget);
    });

    testWidgets('should show cancel confirmation dialog', (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      await tester.tap(find.text('예약 취소'));
      await tester.pumpAndSettle();

      expect(find.text('예약을 취소하시겠습니까?'), findsOneWidget);
      expect(find.text('아니오'), findsOneWidget);
      expect(find.text('취소하기'), findsOneWidget);
    });

    testWidgets('should display error when API fails and not in cache',
        (tester) async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => const Right([]));
      when(() => mockGetReservationUseCase('non-existent'))
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getMyReservationsUseCaseProvider.overrideWithValue(mockGetUseCase),
            cancelReservationUseCaseProvider
                .overrideWithValue(mockCancelUseCase),
            getReservationUseCaseProvider
                .overrideWithValue(mockGetReservationUseCase),
          ],
          child: const MaterialApp(
            home: ReservationDetailPage(reservationId: 'non-existent'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('서버 오류'), findsOneWidget);
    });

    testWidgets('should display review button for completed reservation',
        (tester) async {
      await pumpDetailPage(tester, 'res-3', [tCompletedReservation]);

      expect(find.text('리뷰 작성하기'), findsOneWidget);
    });

    testWidgets('should not display review button for pending reservation',
        (tester) async {
      await pumpDetailPage(tester, 'res-1', [tReservation]);

      expect(find.text('리뷰 작성하기'), findsNothing);
    });

    testWidgets('should fetch from API when reservation is not in cache',
        (tester) async {
      await pumpDetailPageFromApi(tester, 'res-3', tCompletedReservation);

      expect(find.text('젤네일'), findsOneWidget);
      expect(find.text('젤로네일'), findsOneWidget);
      verify(() => mockGetReservationUseCase('res-3')).called(1);
    });
  });
}
