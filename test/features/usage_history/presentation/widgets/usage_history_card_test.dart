import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';
import 'package:jellomark/features/usage_history/presentation/widgets/usage_history_card.dart';

void main() {
  final tUsageHistory = UsageHistory(
    id: 'uh-1',
    memberId: 'member-1',
    shopId: 'shop-1',
    reservationId: 'reservation-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    completedAt: DateTime(2026, 1, 15, 14, 0),
    createdAt: DateTime(2026, 1, 15, 14, 0),
  );

  Widget buildWidget({
    required UsageHistory history,
    VoidCallback? onRebook,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: UsageHistoryCard(
          history: history,
          onRebook: onRebook ?? () {},
        ),
      ),
    );
  }

  group('UsageHistoryCard', () {
    testWidgets('should display shop name', (tester) async {
      await tester.pumpWidget(buildWidget(history: tUsageHistory));

      expect(find.text('젤로네일'), findsOneWidget);
    });

    testWidgets('should display treatment name', (tester) async {
      await tester.pumpWidget(buildWidget(history: tUsageHistory));

      expect(find.text('젤네일'), findsOneWidget);
    });

    testWidgets('should display formatted price', (tester) async {
      await tester.pumpWidget(buildWidget(history: tUsageHistory));

      expect(find.textContaining('30,000'), findsOneWidget);
    });

    testWidgets('should display duration', (tester) async {
      await tester.pumpWidget(buildWidget(history: tUsageHistory));

      expect(find.textContaining('60분'), findsOneWidget);
    });

    testWidgets('should display completed date', (tester) async {
      await tester.pumpWidget(buildWidget(history: tUsageHistory));

      expect(find.textContaining('2026'), findsOneWidget);
    });

    testWidgets('should display rebook button', (tester) async {
      await tester.pumpWidget(buildWidget(history: tUsageHistory));

      expect(find.text('또 예약하기'), findsOneWidget);
    });

    testWidgets('should call onRebook when button is tapped', (tester) async {
      var rebooked = false;
      await tester.pumpWidget(buildWidget(
        history: tUsageHistory,
        onRebook: () => rebooked = true,
      ));

      await tester.tap(find.text('또 예약하기'));
      expect(rebooked, true);
    });
  });
}
