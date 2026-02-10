import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/domain/usecases/cancel_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_my_reservations_usecase.dart';
import 'package:jellomark/features/reservation/presentation/pages/my_reservations_page.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_card.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMyReservationsUseCase extends Mock
    implements GetMyReservationsUseCase {}

class MockCancelReservationUseCase extends Mock
    implements CancelReservationUseCase {}

void main() {
  late MockGetMyReservationsUseCase mockGetUseCase;
  late MockCancelReservationUseCase mockCancelUseCase;

  setUp(() {
    mockGetUseCase = MockGetMyReservationsUseCase();
    mockCancelUseCase = MockCancelReservationUseCase();
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
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  final tConfirmedReservation = Reservation(
    id: 'res-2',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    shopName: '젤로네일',
    treatmentName: '속눈썹',
    reservationDate: '2025-06-16',
    startTime: '10:00',
    endTime: '11:00',
    status: ReservationStatus.confirmed,
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  Widget createPage() {
    return ProviderScope(
      overrides: [
        getMyReservationsUseCaseProvider.overrideWithValue(mockGetUseCase),
        cancelReservationUseCaseProvider.overrideWithValue(mockCancelUseCase),
      ],
      child: const MaterialApp(
        home: MyReservationsPage(),
      ),
    );
  }

  group('MyReservationsPage', () {
    testWidgets('should display app bar with title', (tester) async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => Right([tReservation]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.text('내 예약'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (tester) async {
      final completer = Completer<Either<Failure, List<Reservation>>>();
      when(() => mockGetUseCase())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createPage());
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(Right([tReservation]));
      await tester.pumpAndSettle();
    });

    testWidgets('should display reservations when loaded', (tester) async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => Right([tReservation]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.byType(ReservationCard), findsOneWidget);
      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('should display empty state when no reservations',
        (tester) async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => const Right(<Reservation>[]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.text('예약 내역이 없습니다'), findsOneWidget);
    });

    testWidgets('should display error state when loading fails',
        (tester) async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.text('서버 오류'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should display filter chips', (tester) async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => Right([tReservation, tConfirmedReservation]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilterChip, '전체'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, '대기중'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, '확정'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, '완료'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, '취소'), findsOneWidget);
    });

    testWidgets('should filter by status when chip is tapped', (tester) async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => Right([tReservation, tConfirmedReservation]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.byType(ReservationCard), findsNWidgets(2));

      await tester.tap(find.widgetWithText(FilterChip, '대기중'));
      await tester.pumpAndSettle();

      expect(find.byType(ReservationCard), findsOneWidget);
    });
  });
}
