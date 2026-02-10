import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_summary_card.dart';

void main() {
  group('ReservationSummaryCard', () {
    Widget buildWidget({
      String treatmentName = '젤네일',
      int treatmentPrice = 50000,
      int? durationMinutes = 60,
      String date = '2025-06-15',
      String time = '14:00',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ReservationSummaryCard(
            treatmentName: treatmentName,
            treatmentPrice: treatmentPrice,
            durationMinutes: durationMinutes,
            date: date,
            time: time,
          ),
        ),
      );
    }

    testWidgets('should display reservation info header', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('예약 정보'), findsOneWidget);
    });

    testWidgets('should display treatment name', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('should display formatted price', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('50,000원'), findsOneWidget);
    });

    testWidgets('should display formatted duration', (tester) async {
      await tester.pumpWidget(buildWidget(durationMinutes: 90));

      expect(find.text('1시간 30분'), findsOneWidget);
    });

    testWidgets('should hide duration when null', (tester) async {
      await tester.pumpWidget(buildWidget(durationMinutes: null));

      expect(find.text('소요시간'), findsNothing);
    });

    testWidgets('should display formatted date', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('2025년 6월 15일'), findsOneWidget);
    });

    testWidgets('should display time', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('14:00'), findsOneWidget);
    });
  });
}
