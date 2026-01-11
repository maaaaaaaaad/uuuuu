import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/app_snackbar.dart';

void main() {
  group('AppSnackbar', () {
    testWidgets('should show success snackbar with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => AppSnackbar.showSuccess(
                  context: context,
                  message: '저장되었습니다',
                ),
                child: const Text('스낵바 열기'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('스낵바 열기'));
      await tester.pump();

      expect(find.text('저장되었습니다'), findsOneWidget);
    });

    testWidgets('should show error snackbar with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => AppSnackbar.showError(
                  context: context,
                  message: '오류가 발생했습니다',
                ),
                child: const Text('스낵바 열기'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('스낵바 열기'));
      await tester.pump();

      expect(find.text('오류가 발생했습니다'), findsOneWidget);
    });

    testWidgets('should show info snackbar with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => AppSnackbar.showInfo(
                  context: context,
                  message: '정보를 확인해주세요',
                ),
                child: const Text('스낵바 열기'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('스낵바 열기'));
      await tester.pump();

      expect(find.text('정보를 확인해주세요'), findsOneWidget);
    });

    testWidgets('should show warning snackbar with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => AppSnackbar.showWarning(
                  context: context,
                  message: '주의가 필요합니다',
                ),
                child: const Text('스낵바 열기'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('스낵바 열기'));
      await tester.pump();

      expect(find.text('주의가 필요합니다'), findsOneWidget);
    });

    testWidgets('should show success icon for success snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () =>
                    AppSnackbar.showSuccess(context: context, message: '성공'),
                child: const Text('스낵바 열기'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('스낵바 열기'));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show error icon for error snackbar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () =>
                    AppSnackbar.showError(context: context, message: '에러'),
                child: const Text('스낵바 열기'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('스낵바 열기'));
      await tester.pump();

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should show action button when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => AppSnackbar.showInfo(
                  context: context,
                  message: '메시지',
                  actionLabel: '실행취소',
                  onAction: () {},
                ),
                child: const Text('스낵바 열기'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('스낵바 열기'));
      await tester.pump();

      expect(find.text('실행취소'), findsOneWidget);
    });

    testWidgets('should call onAction when action button is tapped', (
      tester,
    ) async {
      var actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => AppSnackbar.showInfo(
                  context: context,
                  message: '메시지',
                  actionLabel: '실행취소',
                  onAction: () => actionCalled = true,
                ),
                child: const Text('스낵바 열기'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('스낵바 열기'));
      await tester.pump();

      final snackBarAction = tester.widget<SnackBarAction>(
        find.byType(SnackBarAction),
      );
      snackBarAction.onPressed();

      expect(actionCalled, isTrue);
    });
  });
}
