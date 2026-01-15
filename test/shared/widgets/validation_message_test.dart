import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/validation_message.dart';

void main() {
  group('ValidationMessage', () {
    testWidgets('should render error message with error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationMessage(
              message: '필수 입력 항목입니다',
              type: ValidationType.error,
            ),
          ),
        ),
      );

      expect(find.text('필수 입력 항목입니다'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should render success message with check icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationMessage(
              message: '사용 가능한 이메일입니다',
              type: ValidationType.success,
            ),
          ),
        ),
      );

      expect(find.text('사용 가능한 이메일입니다'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('should render warning message with warning icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationMessage(
              message: '비밀번호가 약합니다',
              type: ValidationType.warning,
            ),
          ),
        ),
      );

      expect(find.text('비밀번호가 약합니다'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('should render info message with info icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationMessage(
              message: '8자 이상 입력해주세요',
              type: ValidationType.info,
            ),
          ),
        ),
      );

      expect(find.text('8자 이상 입력해주세요'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should use error color for error type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationMessage(message: '에러', type: ValidationType.error),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, equals(SemanticColors.state.error));
    });

    testWidgets('should use success color for success type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationMessage(
              message: '성공',
              type: ValidationType.success,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle_outline));
      expect(icon.color, equals(SemanticColors.state.success));
    });

    testWidgets('should use warning color for warning type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationMessage(
              message: '경고',
              type: ValidationType.warning,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.warning_amber_outlined),
      );
      expect(icon.color, equals(SemanticColors.state.warning));
    });

    testWidgets('should render nothing when message is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationMessage(message: null, type: ValidationType.error),
          ),
        ),
      );

      expect(find.byType(ValidationMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should render nothing when message is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationMessage(message: '', type: ValidationType.error),
          ),
        ),
      );

      expect(find.byType(ValidationMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });
}
