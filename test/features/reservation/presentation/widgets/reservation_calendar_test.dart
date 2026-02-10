import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_calendar.dart';

void main() {
  group('ReservationCalendar', () {
    late DateTime futureMonth;
    late String futureDate15;
    late String futureDate16;

    setUp(() {
      final now = DateTime.now();
      futureMonth = DateTime(now.year, now.month + 2);
      final y = futureMonth.year;
      final m = futureMonth.month.toString().padLeft(2, '0');
      futureDate15 = '$y-$m-15';
      futureDate16 = '$y-$m-16';
    });

    Widget buildWidget({
      DateTime? displayedMonth,
      Set<String>? availableDates,
      String? selectedDate,
      ValueChanged<String>? onDateSelected,
      ValueChanged<DateTime>? onMonthChanged,
      bool isLoading = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReservationCalendar(
              displayedMonth: displayedMonth ?? futureMonth,
              availableDates: availableDates ?? {futureDate15, futureDate16},
              selectedDate: selectedDate,
              onDateSelected: onDateSelected ?? (_) {},
              onMonthChanged: onMonthChanged ?? (_) {},
              isLoading: isLoading,
            ),
          ),
        ),
      );
    }

    testWidgets('should display month and year', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(
        find.text('${futureMonth.year}년 ${futureMonth.month}월'),
        findsOneWidget,
      );
    });

    testWidgets('should display weekday headers', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('일'), findsOneWidget);
      expect(find.text('월'), findsOneWidget);
      expect(find.text('토'), findsOneWidget);
    });

    testWidgets('should display day numbers', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('1'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(buildWidget(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should call onDateSelected when available date is tapped',
        (tester) async {
      String? selectedDate;
      await tester.pumpWidget(buildWidget(
        availableDates: {futureDate15},
        onDateSelected: (date) => selectedDate = date,
      ));

      await tester.tap(find.text('15'));
      await tester.pump();

      expect(selectedDate, futureDate15);
    });

    testWidgets('should call onMonthChanged when next arrow is tapped',
        (tester) async {
      DateTime? changedMonth;
      await tester.pumpWidget(buildWidget(
        onMonthChanged: (month) => changedMonth = month,
      ));

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(changedMonth,
          DateTime(futureMonth.year, futureMonth.month + 1));
    });
  });
}
