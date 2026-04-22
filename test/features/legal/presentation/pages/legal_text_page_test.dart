import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/legal/presentation/pages/legal_text_page.dart';

void main() {
  group('LegalTextPage', () {
    testWidgets('제목과 본문이 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalTextPage(
            title: '이용약관',
            body: '본문 내용입니다',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('이용약관'), findsOneWidget);
      expect(find.text('본문 내용입니다'), findsOneWidget);
    });
  });
}
