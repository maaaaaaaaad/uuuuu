import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_page.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/operating_hours_card.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/review_card.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/service_menu_item.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_description.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_map_widget.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';

void main() {
  setUp(() {
    ShopMapWidget.useTestMode = true;
  });

  tearDown(() {
    ShopMapWidget.useTestMode = false;
  });

  group('ShopDetailPage', () {
    late ShopDetail testShopDetailWithCoordinates;
    late ShopDetail testShopDetailWithoutCoordinates;
    late List<ServiceMenu> testServices;
    late List<ShopReview> testReviews;

    setUp(() {
      testShopDetailWithCoordinates = const ShopDetail(
        id: 'shop-1',
        name: '블루밍 네일',
        address: '서울시 강남구 역삼동 123-45',
        description: '10년 경력의 네일 아티스트가 운영하는 프리미엄 네일샵입니다.',
        phoneNumber: '02-1234-5678',
        images: [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg',
        ],
        operatingHoursMap: {
          '월': '10:00 - 20:00',
          '화': '10:00 - 20:00',
          '수': '10:00 - 20:00',
          '목': '10:00 - 20:00',
          '금': '10:00 - 21:00',
          '토': '10:00 - 18:00',
          '일': '휴무',
        },
        rating: 4.8,
        reviewCount: 234,
        distance: 0.3,
        tags: ['네일', '젤네일'],
        latitude: 37.5665,
        longitude: 126.9780,
      );

      testShopDetailWithoutCoordinates = const ShopDetail(
        id: 'shop-2',
        name: '블루밍 네일',
        address: '서울시 강남구 역삼동 123-45',
        description: '10년 경력의 네일 아티스트가 운영하는 프리미엄 네일샵입니다.',
        phoneNumber: '02-1234-5678',
        images: [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg',
        ],
        operatingHoursMap: {
          '월': '10:00 - 20:00',
          '화': '10:00 - 20:00',
          '수': '10:00 - 20:00',
          '목': '10:00 - 20:00',
          '금': '10:00 - 21:00',
          '토': '10:00 - 18:00',
          '일': '휴무',
        },
        rating: 4.8,
        reviewCount: 234,
        distance: 0.3,
        tags: ['네일', '젤네일'],
        latitude: null,
        longitude: null,
      );

      testServices = const [
        ServiceMenu(
          id: 'service-1',
          name: '젤네일 기본',
          price: 50000,
          durationMinutes: 60,
          description: '기본 젤네일 시술',
        ),
        ServiceMenu(
          id: 'service-2',
          name: '젤네일 아트',
          price: 70000,
          durationMinutes: 90,
          description: '아트 포함 젤네일',
        ),
      ];

      testReviews = [
        ShopReview(
          id: 'review-1',
          authorName: '김민지',
          rating: 5.0,
          content: '너무 예쁘게 해주셨어요! 다음에도 또 올게요.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          serviceName: '젤네일 기본',
        ),
        ShopReview(
          id: 'review-2',
          authorName: '이수진',
          rating: 4.5,
          content: '친절하고 꼼꼼하게 해주셔서 만족합니다.',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          serviceName: '젤네일 아트',
        ),
      ];
    });

    Widget createShopDetailPage({
      ShopDetail? shopDetail,
      List<ServiceMenu>? services,
      List<ShopReview>? reviews,
      List<Override>? overrides,
    }) {
      return ProviderScope(
        overrides:
            overrides ??
            [currentLocationProvider.overrideWith((ref) async => null)],
        child: MaterialApp(
          home: ShopDetailPage(
            shopDetail: shopDetail ?? testShopDetailWithoutCoordinates,
            services: services ?? testServices,
            reviews: reviews ?? testReviews,
          ),
        ),
      );
    }

    group('basic rendering', () {
      testWidgets('should render shop detail page', (tester) async {
        await tester.pumpWidget(createShopDetailPage());

        expect(find.byType(ShopDetailPage), findsOneWidget);
      });

      testWidgets('should render as ConsumerStatefulWidget', (tester) async {
        await tester.pumpWidget(createShopDetailPage());

        final widget = tester.widget<ShopDetailPage>(
          find.byType(ShopDetailPage),
        );
        expect(widget, isA<ConsumerStatefulWidget>());
      });
    });

    group('fallback layout (no coordinates)', () {
      testWidgets('should use CustomScrollView when no coordinates', (
        tester,
      ) async {
        await tester.pumpWidget(
          createShopDetailPage(shopDetail: testShopDetailWithoutCoordinates),
        );

        expect(find.byType(CustomScrollView), findsOneWidget);
      });

      testWidgets('should display SliverAppBar with back button', (
        tester,
      ) async {
        await tester.pumpWidget(
          createShopDetailPage(shopDetail: testShopDetailWithoutCoordinates),
        );

        expect(find.byType(SliverAppBar), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('should display shop name in app bar when collapsed', (
        tester,
      ) async {
        await tester.pumpWidget(
          createShopDetailPage(shopDetail: testShopDetailWithoutCoordinates),
        );

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();

        expect(find.text('블루밍 네일'), findsAtLeastNWidgets(1));
      });
    });

    group('backdrop map layout (with coordinates)', () {
      testWidgets('should use Stack layout when coordinates present', (
        tester,
      ) async {
        await tester.pumpWidget(
          createShopDetailPage(shopDetail: testShopDetailWithCoordinates),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Stack), findsAtLeastNWidgets(1));
      });

      testWidgets('should display ShopMapWidget in background', (tester) async {
        await tester.pumpWidget(
          createShopDetailPage(shopDetail: testShopDetailWithCoordinates),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ShopMapWidget), findsOneWidget);
      });

      testWidgets('should display DraggableScrollableSheet as foreground', (
        tester,
      ) async {
        await tester.pumpWidget(
          createShopDetailPage(shopDetail: testShopDetailWithCoordinates),
        );
        await tester.pumpAndSettle();

        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });

      testWidgets('should display back button overlay', (tester) async {
        await tester.pumpWidget(
          createShopDetailPage(shopDetail: testShopDetailWithCoordinates),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('content display', () {
      testWidgets('should display shop info header', (tester) async {
        await tester.pumpWidget(createShopDetailPage());

        expect(find.text('블루밍 네일'), findsOneWidget);
        expect(find.text('4.8'), findsOneWidget);
      });

      testWidgets('should display shop description section', (tester) async {
        await tester.pumpWidget(createShopDetailPage());

        expect(find.byType(ShopDescription), findsOneWidget);
      });

      testWidgets('should display operating hours card', (tester) async {
        await tester.pumpWidget(createShopDetailPage());

        expect(find.byType(OperatingHoursCard), findsOneWidget);
      });

      testWidgets('should display service menu section with title', (
        tester,
      ) async {
        await tester.pumpWidget(createShopDetailPage());

        expect(find.text('시술 메뉴'), findsOneWidget);
      });

      testWidgets('should display service menu items', (tester) async {
        await tester.pumpWidget(createShopDetailPage());

        expect(find.byType(ServiceMenuItem), findsNWidgets(2));
        expect(find.text('50,000원'), findsOneWidget);
        expect(find.text('70,000원'), findsOneWidget);
      });

      testWidgets('should display bottom reservation button', (tester) async {
        await tester.pumpWidget(createShopDetailPage());

        expect(find.text('예약하기'), findsOneWidget);
      });
    });

    group('review section', () {
      testWidgets(
        'should display review section with title (fallback layout)',
        (tester) async {
          await tester.pumpWidget(
            createShopDetailPage(shopDetail: testShopDetailWithoutCoordinates),
          );

          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -500),
          );
          await tester.pumpAndSettle();

          expect(find.text('리뷰'), findsOneWidget);
        },
      );

      testWidgets('should display review cards (fallback layout)', (
        tester,
      ) async {
        await tester.pumpWidget(
          createShopDetailPage(shopDetail: testShopDetailWithoutCoordinates),
        );

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();

        expect(find.byType(ReviewCard), findsNWidgets(2));
      });
    });

    group('navigation', () {
      testWidgets('should navigate back when back button is tapped', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentLocationProvider.overrideWith((ref) async => null),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShopDetailPage(
                            shopDetail: testShopDetailWithoutCoordinates,
                            services: testServices,
                            reviews: testReviews,
                          ),
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

        expect(find.byType(ShopDetailPage), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.byType(ShopDetailPage), findsNothing);
      });
    });

    group('location provider integration', () {
      testWidgets('should pass user location to ShopMapWidget when available', (
        tester,
      ) async {
        const mockLocation = UserLocation(
          latitude: 37.5700,
          longitude: 126.9800,
        );

        await tester.pumpWidget(
          createShopDetailPage(
            shopDetail: testShopDetailWithCoordinates,
            overrides: [
              currentLocationProvider.overrideWith((ref) async => mockLocation),
            ],
          ),
        );
        await tester.pumpAndSettle();

        final mapWidget = tester.widget<ShopMapWidget>(
          find.byType(ShopMapWidget),
        );
        expect(mapWidget.userLatitude, mockLocation.latitude);
        expect(mapWidget.userLongitude, mockLocation.longitude);
      });

      testWidgets('should handle null user location gracefully', (
        tester,
      ) async {
        await tester.pumpWidget(
          createShopDetailPage(
            shopDetail: testShopDetailWithCoordinates,
            overrides: [
              currentLocationProvider.overrideWith((ref) async => null),
            ],
          ),
        );
        await tester.pumpAndSettle();

        final mapWidget = tester.widget<ShopMapWidget>(
          find.byType(ShopMapWidget),
        );
        expect(mapWidget.userLatitude, isNull);
        expect(mapWidget.userLongitude, isNull);
      });
    });

    group('image gallery', () {
      testWidgets('should display image gallery in expanded app bar', (
        tester,
      ) async {
        await tester.pumpWidget(
          createShopDetailPage(shopDetail: testShopDetailWithoutCoordinates),
        );

        final sliverAppBar = tester.widget<SliverAppBar>(
          find.byType(SliverAppBar),
        );
        expect(sliverAppBar.expandedHeight, greaterThan(200));
      });
    });
  });
}
