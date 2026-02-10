import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/presentation/widgets/current_reservation_bar.dart';

void main() {
  final now = DateTime.now();
  final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  Reservation makeReservation({
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
      reservationDate: todayStr,
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
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CurrentReservationBar(
          reservation: reservation,
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  group('CurrentReservationBar', () {
    testWidgets('should display treatment name', (tester) async {
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(),
      ));

      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('should display time range and shop name', (tester) async {
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(
          startTime: '14:00',
          endTime: '15:00',
          shopName: '뷰티샵',
        ),
      ));

      expect(
        find.textContaining('14:00 - 15:00'),
        findsOneWidget,
      );
      expect(
        find.textContaining('뷰티샵'),
        findsOneWidget,
      );
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(),
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(CurrentReservationBar));
      expect(tapped, true);
    });

    testWidgets('should display chevron right icon', (tester) async {
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(),
      ));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should handle null treatment name gracefully',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        reservation: makeReservation(treatmentName: null),
      ));

      expect(find.byType(CurrentReservationBar), findsOneWidget);
    });
  });
}
