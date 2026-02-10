import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';
import 'package:jellomark/features/reservation/presentation/widgets/time_slot_grid.dart';

void main() {
  group('TimeSlotGrid', () {
    const tSlots = [
      AvailableSlot(startTime: '10:00', available: true),
      AvailableSlot(startTime: '10:30', available: false),
      AvailableSlot(startTime: '11:00', available: true),
    ];

    Widget buildWidget({
      List<AvailableSlot> slots = tSlots,
      String? selectedTime,
      ValueChanged<String>? onTimeSelected,
      bool isLoading = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TimeSlotGrid(
            slots: slots,
            selectedTime: selectedTime,
            onTimeSelected: onTimeSelected ?? (_) {},
            isLoading: isLoading,
          ),
        ),
      );
    }

    testWidgets('should display all slot times', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('11:00'), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(buildWidget(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show empty message when no slots', (tester) async {
      await tester.pumpWidget(buildWidget(slots: []));

      expect(find.text('예약 가능한 시간이 없습니다'), findsOneWidget);
    });

    testWidgets('should call onTimeSelected when available slot is tapped',
        (tester) async {
      String? selected;
      await tester.pumpWidget(buildWidget(
        onTimeSelected: (time) => selected = time,
      ));

      await tester.tap(find.text('10:00'));
      await tester.pump();

      expect(selected, '10:00');
    });

    testWidgets('should not call onTimeSelected when unavailable slot is tapped',
        (tester) async {
      String? selected;
      await tester.pumpWidget(buildWidget(
        onTimeSelected: (time) => selected = time,
      ));

      await tester.tap(find.text('10:30'));
      await tester.pump();

      expect(selected, isNull);
    });
  });
}
