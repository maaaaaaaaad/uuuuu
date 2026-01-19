import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_map_widget.dart';
import 'package:jellomark/features/location/domain/entities/route.dart';

void main() {
  setUp(() {
    ShopMapWidget.useTestMode = true;
  });

  tearDown(() {
    ShopMapWidget.useTestMode = false;
  });

  group('ShopMapWidget', () {
    group('rendering tests', () {
      testWidgets('should render with required parameters', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
              ),
            ),
          ),
        );

        expect(find.byType(ShopMapWidget), findsOneWidget);
      });

      testWidgets('should render as StatefulWidget', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));
        expect(widget, isA<StatefulWidget>());
      });
    });

    group('parameter tests', () {
      testWidgets('should accept required latitude and longitude',
          (tester) async {
        const latitude = 37.5665;
        const longitude = 126.9780;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: latitude,
                shopLongitude: longitude,
                shopName: '블루밍 네일',
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.shopLatitude, latitude);
        expect(widget.shopLongitude, longitude);
      });

      testWidgets('should accept shopName parameter', (tester) async {
        const shopName = '블루밍 네일';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: shopName,
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.shopName, shopName);
      });

      testWidgets('should accept optional user location parameters',
          (tester) async {
        const userLat = 37.5700;
        const userLng = 126.9800;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                userLatitude: userLat,
                userLongitude: userLng,
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.userLatitude, userLat);
        expect(widget.userLongitude, userLng);
      });

      testWidgets('should handle null user location gracefully',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                userLatitude: null,
                userLongitude: null,
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.userLatitude, isNull);
        expect(widget.userLongitude, isNull);
      });
    });

    group('test mode placeholder tests', () {
      testWidgets('should show map icon in test mode', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      });

      testWidgets('should display shop name in test placeholder',
          (tester) async {
        const shopName = '블루밍 네일';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: shopName,
              ),
            ),
          ),
        );

        expect(find.text(shopName), findsOneWidget);
      });
    });

    group('route coordinates tests', () {
      testWidgets('should accept optional routeCoordinates parameter',
          (tester) async {
        const routeCoordinates = [
          LatLng(latitude: 37.5665, longitude: 126.9780),
          LatLng(latitude: 37.5680, longitude: 126.9790),
          LatLng(latitude: 37.5700, longitude: 126.9800),
        ];

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                routeCoordinates: routeCoordinates,
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.routeCoordinates, equals(routeCoordinates));
        expect(widget.routeCoordinates!.length, 3);
      });

      testWidgets('should render when routeCoordinates is null',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                routeCoordinates: null,
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.routeCoordinates, isNull);
        expect(find.byType(ShopMapWidget), findsOneWidget);
      });

      testWidgets('should render when routeCoordinates is empty',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                routeCoordinates: [],
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.routeCoordinates, isEmpty);
        expect(find.byType(ShopMapWidget), findsOneWidget);
      });

      testWidgets('should render with single coordinate in route',
          (tester) async {
        const routeCoordinates = [
          LatLng(latitude: 37.5665, longitude: 126.9780),
        ];

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                routeCoordinates: routeCoordinates,
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.routeCoordinates!.length, 1);
        expect(find.byType(ShopMapWidget), findsOneWidget);
      });
    });

    group('gesture configuration tests', () {
      testWidgets('should have interactive mode enabled by default',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.interactiveMode, isTrue);
      });

      testWidgets('should allow disabling interactive mode',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                interactiveMode: false,
              ),
            ),
          ),
        );

        final widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));

        expect(widget.interactiveMode, isFalse);
      });
    });

    group('didUpdateWidget tests', () {
      testWidgets('should rebuild when routeCoordinates changes',
          (tester) async {
        const initialCoords = [
          LatLng(latitude: 37.5665, longitude: 126.9780),
          LatLng(latitude: 37.5700, longitude: 126.9800),
        ];
        const updatedCoords = [
          LatLng(latitude: 37.5665, longitude: 126.9780),
          LatLng(latitude: 37.5680, longitude: 126.9790),
          LatLng(latitude: 37.5700, longitude: 126.9800),
        ];

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                routeCoordinates: initialCoords,
              ),
            ),
          ),
        );

        var widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));
        expect(widget.routeCoordinates!.length, 2);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                routeCoordinates: updatedCoords,
              ),
            ),
          ),
        );

        widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));
        expect(widget.routeCoordinates!.length, 3);
      });

      testWidgets('should rebuild when userLocation changes',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                userLatitude: null,
                userLongitude: null,
              ),
            ),
          ),
        );

        var widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));
        expect(widget.userLatitude, isNull);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShopMapWidget(
                shopLatitude: 37.5665,
                shopLongitude: 126.9780,
                shopName: '블루밍 네일',
                userLatitude: 37.5700,
                userLongitude: 126.9800,
              ),
            ),
          ),
        );

        widget = tester.widget<ShopMapWidget>(find.byType(ShopMapWidget));
        expect(widget.userLatitude, 37.5700);
        expect(widget.userLongitude, 126.9800);
      });
    });
  });
}
