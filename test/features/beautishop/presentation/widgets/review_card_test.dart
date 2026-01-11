import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/review_card.dart';

void main() {
  group('ReviewCard', () {
    testWidgets('should display author name', (tester) async {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: DateTime(2024, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );

      expect(find.text('김민지'), findsOneWidget);
    });

    testWidgets('should display rating stars', (tester) async {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: DateTime(2024, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('should display review content', (tester) async {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '네일 너무 예쁘게 해주셨어요!',
        createdAt: DateTime(2024, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );

      expect(find.text('네일 너무 예쁘게 해주셨어요!'), findsOneWidget);
    });

    testWidgets('should display formatted date', (tester) async {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: DateTime(2024, 1, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );

      expect(find.text('2024.01.15'), findsOneWidget);
    });

    testWidgets('should display service name when provided', (tester) async {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: DateTime(2024, 1, 15),
        serviceName: '젤네일 기본',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );

      expect(find.text('젤네일 기본'), findsOneWidget);
    });

    testWidgets('should display images when provided', (tester) async {
      final review = ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '좋아요!',
        createdAt: DateTime(2024, 1, 15),
        images: ['image1.jpg', 'image2.jpg'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );

      expect(find.byKey(const Key('review_images')), findsOneWidget);
    });
  });
}
