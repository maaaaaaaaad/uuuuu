import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_status_badge.dart';

void main() {
  group('ReservationStatusBadge', () {
    Widget createBadge(ReservationStatus status) {
      return MaterialApp(
        home: Scaffold(
          body: ReservationStatusBadge(status: status),
        ),
      );
    }

    testWidgets('should display pending label', (tester) async {
      await tester.pumpWidget(createBadge(ReservationStatus.pending));

      expect(find.text('대기중'), findsOneWidget);
    });

    testWidgets('should display confirmed label', (tester) async {
      await tester.pumpWidget(createBadge(ReservationStatus.confirmed));

      expect(find.text('확정'), findsOneWidget);
    });

    testWidgets('should display rejected label', (tester) async {
      await tester.pumpWidget(createBadge(ReservationStatus.rejected));

      expect(find.text('거절'), findsOneWidget);
    });

    testWidgets('should display cancelled label', (tester) async {
      await tester.pumpWidget(createBadge(ReservationStatus.cancelled));

      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('should display completed label', (tester) async {
      await tester.pumpWidget(createBadge(ReservationStatus.completed));

      expect(find.text('완료'), findsOneWidget);
    });

    testWidgets('should display noShow label', (tester) async {
      await tester.pumpWidget(createBadge(ReservationStatus.noShow));

      expect(find.text('노쇼'), findsOneWidget);
    });

    testWidgets('should be a Container widget', (tester) async {
      await tester.pumpWidget(createBadge(ReservationStatus.pending));

      expect(find.byType(ReservationStatusBadge), findsOneWidget);
    });
  });
}
