import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/review/presentation/providers/review_provider.dart';
import 'package:jellomark/features/treatment/presentation/providers/treatment_provider.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/widgets/glass_card.dart';

import '../../../../helpers/mock_http_client.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('ShopDetailScreen', () {
    late BeautyShop testShop;

    setUp(() {
      testShop = const BeautyShop(
        id: 'shop-1',
        name: '블루밍 네일',
        address: '서울시 강남구 역삼동 123-45',
        rating: 4.8,
        reviewCount: 234,
        distance: 0.3,
        tags: ['네일', '젤네일'],
      );
    });

    Widget createShopDetailScreen({
      required BeautyShop shop,
      List<ServiceMenu>? treatments,
      String? errorMessage,
    }) {
      return ProviderScope(
        overrides: [
          shopTreatmentsProvider(shop.id).overrideWith((ref) {
            if (errorMessage != null) {
              throw Exception(errorMessage);
            }
            return Future.value(treatments ?? []);
          }),
          shopReviewsNotifierProvider(shop.id).overrideWith(
            (ref) => _MockShopReviewsNotifier(),
          ),
        ],
        child: MaterialApp(
          home: ShopDetailScreen(shop: shop),
        ),
      );
    }

    testWidgets('should render shop detail screen', (tester) async {
      await tester.pumpWidget(createShopDetailScreen(shop: testShop));
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailScreen), findsOneWidget);
    });

    testWidgets('should display shop name', (tester) async {
      await tester.pumpWidget(createShopDetailScreen(shop: testShop));
      await tester.pumpAndSettle();

      expect(find.text('블루밍 네일'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display SliverAppBar with back button', (
      tester,
    ) async {
      await tester.pumpWidget(createShopDetailScreen(shop: testShop));
      await tester.pumpAndSettle();

      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display bottom reservation button', (tester) async {
      await tester.pumpWidget(createShopDetailScreen(shop: testShop));
      await tester.pumpAndSettle();

      expect(find.text('예약하기'), findsOneWidget);
    });

    testWidgets('should display loading indicator while loading treatments', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shopTreatmentsProvider(testShop.id).overrideWith((ref) async {
              await Future<void>.value();
              return const <ServiceMenu>[];
            }),
            shopReviewsNotifierProvider(testShop.id).overrideWith(
              (ref) => _MockShopReviewsNotifier(),
            ),
          ],
          child: MaterialApp(
            home: ShopDetailScreen(shop: testShop),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should display treatments when loaded', (tester) async {
      const treatments = [
        ServiceMenu(
          id: 'treatment-1',
          name: '젤네일 기본',
          price: 50000,
          durationMinutes: 60,
        ),
        ServiceMenu(
          id: 'treatment-2',
          name: '젤네일 아트',
          price: 70000,
          durationMinutes: 90,
        ),
      ];

      await tester.pumpWidget(
        createShopDetailScreen(shop: testShop, treatments: treatments),
      );
      await tester.pumpAndSettle();

      expect(find.text('시술 메뉴'), findsOneWidget);
      expect(find.text('50,000원'), findsOneWidget);
      expect(find.text('70,000원'), findsOneWidget);
    });

    testWidgets('should hide service menu section when no treatments', (
      tester,
    ) async {
      await tester.pumpWidget(
        createShopDetailScreen(shop: testShop, treatments: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('시술 메뉴'), findsNothing);
    });

    testWidgets('should display error message when loading fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        createShopDetailScreen(
          shop: testShop,
          errorMessage: '시술 정보를 불러올 수 없습니다',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('시술 정보를 불러올 수 없습니다'), findsOneWidget);
    });

    testWidgets('should navigate back when back button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shopTreatmentsProvider('shop-1').overrideWith((ref) async => []),
            shopReviewsNotifierProvider('shop-1').overrideWith(
              (ref) => _MockShopReviewsNotifier(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopDetailScreen(shop: testShop),
                      ),
                    );
                  },
                  child: const Text('Go to detail'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to detail'));
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailScreen), findsNothing);
    });

    group('UI Redesign', () {
      testWidgets('has lavender gradient background', (tester) async {
        await tester.pumpWidget(createShopDetailScreen(shop: testShop));
        await tester.pumpAndSettle();

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(Scaffold),
            matching: find.byType(Container).first,
          ),
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.gradient, isNotNull);
      });

      testWidgets('has BackdropFilter for glassmorphism', (tester) async {
        await tester.pumpWidget(createShopDetailScreen(shop: testShop));
        await tester.pumpAndSettle();

        expect(find.byType(BackdropFilter), findsWidgets);
      });

      testWidgets('uses GlassCard for info sections', (tester) async {
        await tester.pumpWidget(createShopDetailScreen(shop: testShop));
        await tester.pumpAndSettle();

        expect(find.byType(GlassCard), findsWidgets);
      });

      testWidgets('CircularProgressIndicator has mint color', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              shopTreatmentsProvider(testShop.id).overrideWith((ref) async {
                await Future<void>.value();
                return const <ServiceMenu>[];
              }),
              shopReviewsNotifierProvider(testShop.id).overrideWith(
                (ref) => _MockShopReviewsNotifier(),
              ),
            ],
            child: MaterialApp(
              home: ShopDetailScreen(shop: testShop),
            ),
          ),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, AppColors.mint);

        await tester.pumpAndSettle();
      });

      testWidgets('reservation button has gradient', (tester) async {
        await tester.pumpWidget(createShopDetailScreen(shop: testShop));
        await tester.pumpAndSettle();

        final containers = tester.widgetList<Container>(find.byType(Container));
        bool hasGradientButton = false;
        for (final container in containers) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.gradient != null) {
            hasGradientButton = true;
            break;
          }
        }
        expect(hasGradientButton, isTrue);
      });
    });
  });
}

class _MockShopReviewsNotifier extends ShopReviewsNotifier {
  _MockShopReviewsNotifier() : super('mock-shop-id', _MockRef());

  @override
  ShopReviewsState get state => const ShopReviewsState();

  @override
  Future<void> loadInitial() async {}

  @override
  Future<void> loadMore() async {}
}

class _MockRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
