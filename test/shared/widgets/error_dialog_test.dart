import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/widgets/error_dialog.dart';

void main() {
  group('ErrorDialog', () {
    testWidgets('should show title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(
                context: context,
                title: '오류',
                message: '문제가 발생했습니다',
              ),
              child: const Text('다이얼로그 열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      expect(find.text('오류'), findsOneWidget);
    });

    testWidgets('should show message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(
                context: context,
                title: '오류',
                message: '네트워크 연결을 확인해주세요',
              ),
              child: const Text('다이얼로그 열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      expect(find.text('네트워크 연결을 확인해주세요'), findsOneWidget);
    });

    testWidgets('should show default confirm button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(
                context: context,
                title: '오류',
                message: '문제가 발생했습니다',
              ),
              child: const Text('다이얼로그 열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      expect(find.text('확인'), findsOneWidget);
    });

    testWidgets('should close when confirm button is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(
                context: context,
                title: '오류',
                message: '문제가 발생했습니다',
              ),
              child: const Text('다이얼로그 열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      expect(find.text('오류'), findsOneWidget);

      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();

      expect(find.text('오류'), findsNothing);
    });

    testWidgets('should use custom confirm button text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(
                context: context,
                title: '오류',
                message: '문제가 발생했습니다',
                confirmText: '닫기',
              ),
              child: const Text('다이얼로그 열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      expect(find.text('닫기'), findsOneWidget);
      expect(find.text('확인'), findsNothing);
    });

    testWidgets('should call onConfirm callback when confirm is tapped', (
      tester,
    ) async {
      var confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(
                context: context,
                title: '오류',
                message: '문제가 발생했습니다',
                onConfirm: () => confirmed = true,
              ),
              child: const Text('다이얼로그 열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('should show error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(
                context: context,
                title: '오류',
                message: '문제가 발생했습니다',
              ),
              child: const Text('다이얼로그 열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should be dismissible by tapping outside', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(
                context: context,
                title: '오류',
                message: '문제가 발생했습니다',
              ),
              child: const Text('다이얼로그 열기'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();

      expect(find.text('오류'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('오류'), findsNothing);
    });
  });
}
