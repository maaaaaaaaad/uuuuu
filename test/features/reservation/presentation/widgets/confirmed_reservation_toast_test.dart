import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/presentation/widgets/confirmed_reservation_toast.dart';

void main() {
  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));
  final tomorrowStr =
      '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

  Reservation makeReservation({
    String? reservationDate,
    String startTime = '14:00',
    String endTime = '15:00',
    String? shopName = '젤로네일',
    String? treatmentName = '젤네일',
  }) {
    return Reservation(
      id: 'r-1',
      shopId: 'shop-1',
      memberId: 'member-1',
      treatmentId: 'treatment-1',
      shopName: shopName,
      treatmentName: treatmentName,
      treatmentPrice: 30000,
      treatmentDuration: 60,
      reservationDate: reservationDate ?? tomorrowStr,
      startTime: startTime,
      endTime: endTime,
      status: ReservationStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget buildWidget({
    required Reservation reservation,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ConfirmedReservationToast(
          reservation: reservation,
          onTap: onTap ?? () {},
          onDismiss: onDismiss ?? () {},
        ),
      ),
    );
  }

  group('ConfirmedReservationToast', () {
    testWidgets('should display confirmation message', (tester) async {
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(),
      ));

      expect(find.textContaining('예약이 확정되었습니다'), findsOneWidget);
    });

    testWidgets('should display treatment name', (tester) async {
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(treatmentName: '속눈썹'),
      ));

      expect(find.textContaining('속눈썹'), findsOneWidget);
    });

    testWidgets('should display reservation date and time', (tester) async {
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(startTime: '10:00'),
      ));

      expect(find.textContaining('10:00'), findsOneWidget);
    });

    testWidgets('should call onDismiss when close button is tapped',
        (tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(),
        onDismiss: () => dismissed = true,
      ));

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, true);
    });

    testWidgets('should call onTap when body is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(),
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(ConfirmedReservationToast));
      expect(tapped, true);
    });

    testWidgets('should display close icon', (tester) async {
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should display calendar icon', (tester) async {
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(),
      ));

      expect(find.byIcon(Icons.event_available), findsOneWidget);
    });
  });
}
