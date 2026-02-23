import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/notification/presentation/widgets/notification_permission_dialog.dart';
import 'package:jellomark/shared/theme/app_colors.dart';

void main() {
  group('NotificationPermissionDialog', () {
    Future<void> showDialogInTest(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () =>
                    NotificationPermissionDialog.show(context: context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
    }

    testWidgets('should display notification icon', (tester) async {
      await showDialogInTest(tester);

      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });

    testWidgets('should display permission message', (tester) async {
      await showDialogInTest(tester);

      expect(
        find.text('예약 알림을 받으려면 알림 권한이 필요해요'),
        findsOneWidget,
      );
    });

    testWidgets('should display cancel and settings buttons', (tester) async {
      await showDialogInTest(tester);

      expect(find.text('취소'), findsOneWidget);
      expect(find.text('설정으로 이동'), findsOneWidget);
    });

    testWidgets('cancel button should close dialog', (tester) async {
      await showDialogInTest(tester);

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(find.text('예약 알림을 받으려면 알림 권한이 필요해요'), findsNothing);
    });

    testWidgets('icon has pastel pink color', (tester) async {
      await showDialogInTest(tester);

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.notifications_active),
      );
      expect(icon.color, AppColors.pastelPink);
    });
  });
}
