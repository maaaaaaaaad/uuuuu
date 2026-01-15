import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/write_review_bottom_sheet.dart';
import 'package:jellomark/shared/theme/app_colors.dart';

void main() {
  group('WriteReviewBottomSheet', () {
    Widget createTestWidget({
      required Future<bool> Function({int? rating, String? content}) onSubmit,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                WriteReviewBottomSheet.show(
                  context: context,
                  shopName: '테스트 샵',
                  onSubmit: onSubmit,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
    }

    testWidgets('should display shop name in header', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('테스트 샵'), findsOneWidget);
      expect(find.text('리뷰 작성'), findsOneWidget);
    });

    testWidgets('should display rating section with optional label', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('평점'), findsOneWidget);
      expect(find.text('(선택)'), findsNWidgets(2));
    });

    testWidgets('should display content input field with minimum length hint', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('리뷰 내용'), findsOneWidget);
      expect(find.textContaining('최소 10자'), findsOneWidget);
    });

    testWidgets('should have disabled submit button when empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '작성 완료'),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('should enable submit button when rating is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
      await tester.pumpAndSettle();

      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '작성 완료'),
      );
      expect(submitButton.onPressed, isNotNull);
    });

    testWidgets('should enable submit button when content is 10+ characters', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '정말 좋은 경험이었습니다!');
      await tester.pumpAndSettle();

      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '작성 완료'),
      );
      expect(submitButton.onPressed, isNotNull);
    });

    testWidgets('should show rating text when star is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final stars = find.byIcon(Icons.star_outline_rounded);
      await tester.tap(stars.at(4));
      await tester.pumpAndSettle();

      expect(find.text('최고예요!'), findsOneWidget);
    });

    testWidgets('should call onSubmit with rating when submitted', (
      tester,
    ) async {
      int? submittedRating;
      String? submittedContent;

      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async {
            submittedRating = rating;
            submittedContent = content;
            return true;
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(3));
      await tester.pumpAndSettle();

      await tester.tap(find.text('작성 완료'));
      await tester.pumpAndSettle();

      expect(submittedRating, 4);
      expect(submittedContent, isNull);
    });

    testWidgets('should call onSubmit with content when submitted', (
      tester,
    ) async {
      int? submittedRating;
      String? submittedContent;

      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async {
            submittedRating = rating;
            submittedContent = content;
            return true;
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '정말 좋은 경험이었습니다!');
      await tester.pumpAndSettle();

      await tester.tap(find.text('작성 완료'));
      await tester.pumpAndSettle();

      expect(submittedRating, isNull);
      expect(submittedContent, '정말 좋은 경험이었습니다!');
    });

    testWidgets('should close bottom sheet on success', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('작성 완료'));
      await tester.pumpAndSettle();

      expect(find.text('리뷰 작성'), findsNothing);
    });

    testWidgets('should show error snackbar on failure', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => false,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('작성 완료'));
      await tester.pumpAndSettle();

      expect(find.text('리뷰 작성에 실패했습니다. 다시 시도해주세요.'), findsOneWidget);
    });

    testWidgets(
      'should disable submit button when content is less than 10 characters',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            onSubmit: ({int? rating, String? content}) async => true,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '짧은글');
        await tester.pumpAndSettle();

        final submitButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, '작성 완료'),
        );
        expect(submitButton.onPressed, isNull);
      },
    );

    testWidgets(
      'should enable submit button when content is 10 or more characters',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            onSubmit: ({int? rating, String? content}) async => true,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '이것은 열 글자 이상의 리뷰입니다');
        await tester.pumpAndSettle();

        final submitButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, '작성 완료'),
        );
        expect(submitButton.onPressed, isNotNull);
      },
    );

    testWidgets(
      'should show remaining character count when content is less than 10',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            onSubmit: ({int? rating, String? content}) async => true,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '짧은글');
        await tester.pumpAndSettle();

        expect(find.textContaining('7자 더 입력해주세요'), findsOneWidget);
      },
    );

    testWidgets(
      'should enable submit with rating only (no content validation)',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            onSubmit: ({int? rating, String? content}) async => true,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.star_outline_rounded).at(2));
        await tester.pumpAndSettle();

        final submitButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, '작성 완료'),
        );
        expect(submitButton.onPressed, isNotNull);
      },
    );

    testWidgets('should close when X button is tapped', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          onSubmit: ({int? rating, String? content}) async => true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('리뷰 작성'), findsNothing);
    });

    group('UI Redesign', () {
      testWidgets('has borderRadius 30 for top corners', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            onSubmit: ({int? rating, String? content}) async => true,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final containers = tester.widgetList<Container>(find.byType(Container));
        bool hasRadius30 = false;
        for (final container in containers) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.borderRadius != null) {
            final borderRadius = decoration.borderRadius as BorderRadius;
            if (borderRadius.topLeft.x == 30 && borderRadius.topRight.x == 30) {
              hasRadius30 = true;
              break;
            }
          }
        }
        expect(hasRadius30, isTrue);
      });

      testWidgets('has BackdropFilter for glassmorphism', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            onSubmit: ({int? rating, String? content}) async => true,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(BackdropFilter), findsWidgets);
      });

      testWidgets('handle bar has correct dimensions (width 40, height 4)', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            onSubmit: ({int? rating, String? content}) async => true,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final containers = tester.widgetList<Container>(find.byType(Container));
        bool hasCorrectHandle = false;
        for (final container in containers) {
          if (container.constraints?.maxWidth == 40 &&
              container.constraints?.maxHeight == 4) {
            hasCorrectHandle = true;
            break;
          }
        }
        expect(hasCorrectHandle, isTrue);
      });

      testWidgets('has glassmorphism background color', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            onSubmit: ({int? rating, String? content}) async => true,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final containers = tester.widgetList<Container>(find.byType(Container));
        bool hasGlassBackground = false;
        for (final container in containers) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration &&
              decoration.color == AppColors.glassWhite) {
            hasGlassBackground = true;
            break;
          }
        }
        expect(hasGlassBackground, isTrue);
      });
    });
  });
}
