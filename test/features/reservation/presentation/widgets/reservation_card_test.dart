import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_card.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_status_badge.dart';

void main() {
  group('ReservationCard', () {
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

    Widget createCard({
      Reservation? reservation,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ReservationCard(
            reservation: reservation ?? tReservation,
            onTap: onTap ?? () {},
          ),
        ),
      );
    }

    testWidgets('should display treatment name', (tester) async {
      await tester.pumpWidget(createCard());

      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('should display shop name', (tester) async {
      await tester.pumpWidget(createCard());

      expect(find.text('젤로네일'), findsOneWidget);
    });

    testWidgets('should display date and time', (tester) async {
      await tester.pumpWidget(createCard());

      expect(find.text('2025-06-15'), findsOneWidget);
      expect(find.text('14:00 - 15:00'), findsOneWidget);
    });

    testWidgets('should display status badge', (tester) async {
      await tester.pumpWidget(createCard());

      expect(find.byType(ReservationStatusBadge), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(createCard(onTap: () => tapped = true));
      await tester.tap(find.byType(ReservationCard));

      expect(tapped, true);
    });

    testWidgets('should handle null shop name', (tester) async {
      final reservation = Reservation(
        id: 'res-2',
        shopId: 'shop-1',
        memberId: 'member-1',
        treatmentId: 'treatment-1',
        treatmentName: '젤네일',
        reservationDate: '2025-06-15',
        startTime: '14:00',
        endTime: '15:00',
        status: ReservationStatus.confirmed,
        createdAt: DateTime(2025, 6, 10),
        updatedAt: DateTime(2025, 6, 10),
      );

      await tester.pumpWidget(createCard(reservation: reservation));

      expect(find.byType(ReservationCard), findsOneWidget);
    });
  });
}
