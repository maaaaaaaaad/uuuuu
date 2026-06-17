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

      expect(find.text('예약 알림을 받아보세요'), findsOneWidget);
    });

    testWidgets('should display close and settings buttons', (tester) async {
      await showDialogInTest(tester);

      expect(find.text('닫기'), findsOneWidget);
      expect(find.text('설정으로 이동'), findsOneWidget);
    });

    testWidgets('close button should dismiss dialog', (tester) async {
      await showDialogInTest(tester);

      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();

      expect(find.text('예약 알림을 받아보세요'), findsNothing);
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
