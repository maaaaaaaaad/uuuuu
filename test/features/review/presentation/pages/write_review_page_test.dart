import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/review/presentation/pages/write_review_page.dart';

void main() {
  Widget createPage({
    String shopName = '테스트샵',
    Future<String?> Function({int? rating, String? content})? onSubmit,
  }) {
    return MaterialApp(
      home: WriteReviewPage(
        shopName: shopName,
        onSubmit: onSubmit ?? ({int? rating, String? content}) async => null,
      ),
    );
  }

  group('WriteReviewPage', () {
    testWidgets('should display shop name in app bar', (tester) async {
      await tester.pumpWidget(createPage(shopName: '젤로네일'));
      expect(find.text('젤로네일'), findsOneWidget);
    });

    testWidgets('should display rating section with optional label',
        (tester) async {
      await tester.pumpWidget(createPage());
      expect(find.text('평점'), findsOneWidget);
      expect(find.text('(선택)'), findsNWidgets(2));
    });

    testWidgets('should display content input field', (tester) async {
      await tester.pumpWidget(createPage());
      expect(find.text('리뷰 내용'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display disabled submit button initially',
        (tester) async {
      await tester.pumpWidget(createPage());

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '작성 완료'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should enable submit button when rating is selected',
        (tester) async {
      await tester.pumpWidget(createPage());

      await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '작성 완료'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should show rating text when star is selected',
        (tester) async {
      await tester.pumpWidget(createPage());

      await tester.tap(find.byIcon(Icons.star_outline_rounded).last);
      await tester.pump();

      expect(find.text('최고예요!'), findsOneWidget);
    });

    testWidgets('should enable submit button when content is 10+ characters',
        (tester) async {
      await tester.pumpWidget(createPage());

      await tester.enterText(find.byType(TextField), '정말 좋은 서비스였습니다!');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '작성 완료'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should show remaining character count when content is short',
        (tester) async {
      await tester.pumpWidget(createPage());

      await tester.enterText(find.byType(TextField), '짧은');
      await tester.pump();

      expect(find.textContaining('자 더 입력해주세요'), findsOneWidget);
    });

    testWidgets('should call onSubmit with rating when submitted',
        (tester) async {
      int? submittedRating;

      await tester.pumpWidget(createPage(
        onSubmit: ({int? rating, String? content}) async {
          submittedRating = rating;
          return null;
        },
      ));

      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(2));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, '작성 완료'));
      await tester.pumpAndSettle();

      expect(submittedRating, 3);
    });

    testWidgets('should navigate back on success', (tester) async {
      await tester.pumpWidget(createPage(
        onSubmit: ({int? rating, String? content}) async => null,
      ));

      await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, '작성 완료'));
      await tester.pumpAndSettle();
    });

    testWidgets('should show error snackbar on failure', (tester) async {
      await tester.pumpWidget(createPage(
        onSubmit: ({int? rating, String? content}) async =>
            '리뷰 작성에 실패했습니다. 다시 시도해주세요.',
      ));

      await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, '작성 완료'));
      await tester.pumpAndSettle();

      expect(find.text('리뷰 작성에 실패했습니다. 다시 시도해주세요.'), findsOneWidget);
    });

    testWidgets('should deselect rating when same star tapped again',
        (tester) async {
      await tester.pumpWidget(createPage());

      await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
      await tester.pump();
      expect(find.text('별로예요'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.star_rounded).first);
      await tester.pump();
      expect(find.text('별로예요'), findsNothing);
    });
  });
}
