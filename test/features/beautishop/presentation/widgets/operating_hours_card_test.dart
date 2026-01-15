import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/operating_hours_card.dart';

void main() {
  group('OperatingHoursCard', () {
    testWidgets('should display section title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperatingHoursCard(
              operatingHours: {
                '월': '10:00 - 20:00',
              },
            ),
          ),
        ),
      );

      expect(find.text('영업시간'), findsOneWidget);
    });

    testWidgets('should display all days of week', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperatingHoursCard(
              operatingHours: {
                '월': '10:00 - 20:00',
                '화': '10:00 - 20:00',
                '수': '10:00 - 20:00',
                '목': '10:00 - 20:00',
                '금': '10:00 - 20:00',
                '토': '11:00 - 18:00',
                '일': '휴무',
              },
            ),
          ),
        ),
      );

      expect(find.text('월'), findsOneWidget);
      expect(find.text('화'), findsOneWidget);
      expect(find.text('수'), findsOneWidget);
      expect(find.text('목'), findsOneWidget);
      expect(find.text('금'), findsOneWidget);
      expect(find.text('토'), findsOneWidget);
      expect(find.text('일'), findsOneWidget);
    });

    testWidgets('should display operating hours for each day', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperatingHoursCard(
              operatingHours: {
                '월': '10:00 - 20:00',
                '토': '11:00 - 18:00',
              },
            ),
          ),
        ),
      );

      expect(find.text('10:00 - 20:00'), findsOneWidget);
      expect(find.text('11:00 - 18:00'), findsOneWidget);
    });

    testWidgets('should highlight 휴무 day differently', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperatingHoursCard(
              operatingHours: {
                '일': '휴무',
              },
            ),
          ),
        ),
      );

      final closedText = tester.widget<Text>(find.text('휴무'));
      expect(closedText.style?.color, Colors.red);
    });

    testWidgets('should highlight current day', (tester) async {
      final days = ['일', '월', '화', '수', '목', '금', '토'];
      final today = days[DateTime.now().weekday % 7];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OperatingHoursCard(
              operatingHours: {
                today: '10:00 - 20:00',
              },
            ),
          ),
        ),
      );

      final dayText = tester.widget<Text>(find.text(today));
      expect(dayText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should show notice when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperatingHoursCard(
              operatingHours: {
                '월': '10:00 - 20:00',
              },
              notice: '공휴일 휴무',
            ),
          ),
        ),
      );

      expect(find.text('공휴일 휴무'), findsOneWidget);
    });
  });
}
