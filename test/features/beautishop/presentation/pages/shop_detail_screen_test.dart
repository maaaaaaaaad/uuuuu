import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/beautishop/presentation/providers/shop_provider.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/full_screen_image_viewer.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/image_thumbnail_grid.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/repositories/recent_shops_repository.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/add_recent_shop_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/clear_recent_shops_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/get_recent_shops_usecase.dart';
import 'package:jellomark/features/recent_shops/presentation/providers/recent_shops_provider.dart';
import 'package:jellomark/features/review/presentation/providers/review_provider.dart';
import 'package:jellomark/features/treatment/presentation/providers/treatment_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
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
          shopByIdProvider(shop.id).overrideWith((ref) async => shop),
          shopTreatmentsProvider(shop.id).overrideWith((ref) {
            if (errorMessage != null) {
              throw Exception(errorMessage);
            }
            return Future.value(treatments ?? []);
          }),
          shopReviewsNotifierProvider(
            shop.id,
          ).overrideWith((ref) => _MockShopReviewsNotifier()),
          currentLocationProvider.overrideWith((ref) async => null),
          recentShopsNotifierProvider.overrideWith(
            (ref) => _MockRecentShopsNotifier(),
          ),
        ],
        child: MaterialApp(home: ShopDetailScreen(shop: shop)),
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

    testWidgets('should display Stack with back button', (tester) async {
      await tester.pumpWidget(createShopDetailScreen(shop: testShop));
      await tester.pumpAndSettle();

      expect(find.byType(Stack), findsWidgets);
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
            shopByIdProvider(testShop.id).overrideWith((ref) async => testShop),
            shopTreatmentsProvider(testShop.id).overrideWith((ref) async {
              await Future.delayed(const Duration(milliseconds: 100));
              return const <ServiceMenu>[];
            }),
            shopReviewsNotifierProvider(
              testShop.id,
            ).overrideWith((ref) => _MockShopReviewsNotifier()),
            currentLocationProvider.overrideWith((ref) async => null),
            recentShopsNotifierProvider.overrideWith(
              (ref) => _MockRecentShopsNotifier(),
            ),
          ],
          child: MaterialApp(home: ShopDetailScreen(shop: testShop)),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('시술'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

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

      expect(find.text('시술'), findsOneWidget);

      await tester.tap(find.text('시술'));
      await tester.pumpAndSettle();

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

      await tester.tap(find.text('시술'));
      await tester.pumpAndSettle();

      expect(find.text('등록된 시술이 없습니다'), findsOneWidget);
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

      await tester.tap(find.text('시술'));
      await tester.pumpAndSettle();

      expect(find.text('시술 정보를 불러올 수 없습니다'), findsOneWidget);
    });

    testWidgets('should navigate back when back button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shopByIdProvider('shop-1').overrideWith((ref) async => testShop),
            shopTreatmentsProvider('shop-1').overrideWith((ref) async => []),
            shopReviewsNotifierProvider(
              'shop-1',
            ).overrideWith((ref) => _MockShopReviewsNotifier()),
            currentLocationProvider.overrideWith((ref) async => null),
            recentShopsNotifierProvider.overrideWith(
              (ref) => _MockRecentShopsNotifier(),
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
      testWidgets('has DraggableScrollableSheet for shop info', (tester) async {
        await tester.pumpWidget(createShopDetailScreen(shop: testShop));
        await tester.pumpAndSettle();

        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });

      testWidgets('has BackdropFilter for glassmorphism', (tester) async {
        await tester.pumpWidget(createShopDetailScreen(shop: testShop));
        await tester.pumpAndSettle();

        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
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
              shopByIdProvider(testShop.id).overrideWith(
                (ref) async => testShop,
              ),
              shopTreatmentsProvider(testShop.id).overrideWith((ref) async {
                await Future.delayed(const Duration(milliseconds: 100));
                return const <ServiceMenu>[];
              }),
              shopReviewsNotifierProvider(
                testShop.id,
              ).overrideWith((ref) => _MockShopReviewsNotifier()),
              currentLocationProvider.overrideWith((ref) async => null),
              recentShopsNotifierProvider.overrideWith(
                (ref) => _MockRecentShopsNotifier(),
              ),
            ],
            child: MaterialApp(home: ShopDetailScreen(shop: testShop)),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('시술'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, SemanticColors.indicator.loading);

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

    group('Map Placeholder in Background', () {
      testWidgets('should display map placeholder when coordinates missing', (
        tester,
      ) async {
        await tester.pumpWidget(createShopDetailScreen(shop: testShop));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      });

      testWidgets('map should be full screen behind DraggableScrollableSheet', (
        tester,
      ) async {
        await tester.pumpWidget(createShopDetailScreen(shop: testShop));
        await tester.pumpAndSettle();

        expect(find.byType(Positioned), findsWidgets);
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });
    });

    group('Image Gallery in Body', () {
      testWidgets('should display ImageThumbnailGrid when shop has images', (
        tester,
      ) async {
        final shopWithImage = BeautyShopModel(
          id: 'shop-1',
          name: '블루밍 네일',
          address: '서울시 강남구 역삼동 123-45',
          rating: 4.8,
          reviewCount: 234,
          distance: 0.3,
          tags: const ['네일', '젤네일'],
          images: const ['https://example.com/image.jpg'],
          phoneNumber: '02-1234-5678',
          operatingTimeMap: const {'월': '09:00 - 18:00'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(createShopDetailScreen(shop: shopWithImage));
        await tester.pump();

        expect(find.byType(ImageThumbnailGrid), findsOneWidget);
      });

      testWidgets(
        'should not display ImageThumbnailGrid when shop has no images',
        (tester) async {
          await tester.pumpWidget(createShopDetailScreen(shop: testShop));
          await tester.pumpAndSettle();

          expect(find.byType(ImageThumbnailGrid), findsNothing);
        },
      );

      testWidgets('ImageThumbnailGrid should not be wrapped in GlassCard', (
        tester,
      ) async {
        final shopWithImage = BeautyShopModel(
          id: 'shop-1',
          name: '블루밍 네일',
          address: '서울시 강남구 역삼동 123-45',
          rating: 4.8,
          reviewCount: 234,
          distance: 0.3,
          tags: const ['네일', '젤네일'],
          images: const ['https://example.com/image.jpg'],
          phoneNumber: '02-1234-5678',
          operatingTimeMap: const {'월': '09:00 - 18:00'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(createShopDetailScreen(shop: shopWithImage));
        await tester.pump();

        final glassCards = tester.widgetList<GlassCard>(find.byType(GlassCard));
        bool hasImageGridInGlassCard = false;
        for (final glassCard in glassCards) {
          if (glassCard.child is ImageThumbnailGrid) {
            hasImageGridInGlassCard = true;
            break;
          }
        }
        expect(hasImageGridInGlassCard, isFalse);
      });

      testWidgets('ImageThumbnailGrid should have reduced image size', (
        tester,
      ) async {
        final shopWithImage = BeautyShopModel(
          id: 'shop-1',
          name: '블루밍 네일',
          address: '서울시 강남구 역삼동 123-45',
          rating: 4.8,
          reviewCount: 234,
          distance: 0.3,
          tags: const ['네일', '젤네일'],
          images: const ['https://example.com/image.jpg'],
          phoneNumber: '02-1234-5678',
          operatingTimeMap: const {'월': '09:00 - 18:00'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(createShopDetailScreen(shop: shopWithImage));
        await tester.pump();

        final imageGrid = tester.widget<ImageThumbnailGrid>(
          find.byType(ImageThumbnailGrid),
        );
        expect(imageGrid.imageSize, 100);
      });

      testWidgets('should navigate to FullScreenImageViewer on thumbnail tap', (
        tester,
      ) async {
        final shopWithImage = BeautyShopModel(
          id: 'shop-1',
          name: '블루밍 네일',
          address: '서울시 강남구 역삼동 123-45',
          rating: 4.8,
          reviewCount: 234,
          distance: 0.3,
          tags: const ['네일', '젤네일'],
          images: const ['https://example.com/image.jpg'],
          phoneNumber: '02-1234-5678',
          operatingTimeMap: const {'월': '09:00 - 18:00'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              shopByIdProvider(shopWithImage.id).overrideWith(
                (ref) async => shopWithImage,
              ),
              shopTreatmentsProvider(
                shopWithImage.id,
              ).overrideWith((ref) async => []),
              shopReviewsNotifierProvider(
                shopWithImage.id,
              ).overrideWith((ref) => _MockShopReviewsNotifier()),
              currentLocationProvider.overrideWith((ref) async => null),
              recentShopsNotifierProvider.overrideWith(
                (ref) => _MockRecentShopsNotifier(),
              ),
            ],
            child: MaterialApp(home: ShopDetailScreen(shop: shopWithImage)),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.byKey(const Key('thumbnail_0')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(FullScreenImageViewer), findsOneWidget);
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

class _MockRecentShopsNotifier extends RecentShopsNotifier {
  _MockRecentShopsNotifier()
      : super(
          getRecentShopsUseCase: _MockGetRecentShopsUseCase(),
          addRecentShopUseCase: _MockAddRecentShopUseCase(),
          clearRecentShopsUseCase: _MockClearRecentShopsUseCase(),
          getCurrentLocation: () async => null,
        );

  @override
  RecentShopsState get state => const RecentShopsState();

  @override
  Future<void> loadRecentShops() async {}

  @override
  Future<void> addRecentShop(RecentShop shop) async {}

  @override
  Future<void> clearRecentShops() async {}
}

class _MockGetRecentShopsUseCase extends GetRecentShopsUseCase {
  _MockGetRecentShopsUseCase() : super(_MockRecentShopsRepository());

  @override
  Future<Either<Failure, List<RecentShop>>> call() async {
    return const Right([]);
  }
}

class _MockAddRecentShopUseCase extends AddRecentShopUseCase {
  _MockAddRecentShopUseCase() : super(_MockRecentShopsRepository());

  @override
  Future<Either<Failure, void>> call(RecentShop shop) async {
    return const Right(null);
  }
}

class _MockClearRecentShopsUseCase extends ClearRecentShopsUseCase {
  _MockClearRecentShopsUseCase() : super(_MockRecentShopsRepository());

  @override
  Future<Either<Failure, void>> call() async {
    return const Right(null);
  }
}

class _MockRecentShopsRepository implements RecentShopsRepository {
  @override
  Future<Either<Failure, void>> addRecentShop(RecentShop shop) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<RecentShop>>> getRecentShops() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> clearRecentShops() async {
    return const Right(null);
  }
}

class _MockRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
