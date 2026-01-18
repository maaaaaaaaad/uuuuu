import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/domain/repositories/location_setting_repository.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
import 'package:jellomark/features/location/presentation/widgets/location_permission_alert_dialog.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationSettingRepository extends Mock
    implements LocationSettingRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockLocationSettingRepository mockSettingRepository;
  late MockLocationRepository mockLocationRepository;

  setUp(() {
    mockSettingRepository = MockLocationSettingRepository();
    mockLocationRepository = MockLocationRepository();

    when(() => mockSettingRepository.isLocationEnabled())
        .thenAnswer((_) async => false);
    when(() => mockLocationRepository.checkPermissionStatus())
        .thenAnswer((_) async => LocationPermissionResult.denied);
  });

  Widget createTestWidget({required Widget child}) {
    return ProviderScope(
      overrides: [
        locationSettingRepositoryProvider
            .overrideWithValue(mockSettingRepository),
        locationRepositoryForSettingProvider
            .overrideWithValue(mockLocationRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => child,
          ),
        ),
      ),
    );
  }

  group('LocationPermissionAlertDialog', () {
    testWidgets('should display correct message', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocationPermissionAlertDialog.show(
                    context: context,
                    onAgree: () {},
                    onCancel: () {},
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(
        find.text('젤로마크는 위치 기반 서비스이므로 위치 정보 제공에 동의가 꼭 필요해요'),
        findsOneWidget,
      );
    });

    testWidgets('should display cancel and agree buttons', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocationPermissionAlertDialog.show(
                    context: context,
                    onAgree: () {},
                    onCancel: () {},
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('취소'), findsOneWidget);
      expect(find.text('동의'), findsOneWidget);
    });

    testWidgets('should call onCancel when cancel button tapped', (tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocationPermissionAlertDialog.show(
                    context: context,
                    onAgree: () {},
                    onCancel: () {
                      cancelCalled = true;
                    },
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
    });

    testWidgets('should call onAgree when agree button tapped', (tester) async {
      bool agreeCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocationPermissionAlertDialog.show(
                    context: context,
                    onAgree: () {
                      agreeCalled = true;
                    },
                    onCancel: () {},
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('동의'));
      await tester.pumpAndSettle();

      expect(agreeCalled, isTrue);
    });

    testWidgets('should close dialog when cancel button tapped', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocationPermissionAlertDialog.show(
                    context: context,
                    onAgree: () {},
                    onCancel: () {},
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('취소'), findsOneWidget);

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(
        find.text('젤로마크는 위치 기반 서비스이므로 위치 정보 제공에 동의가 꼭 필요해요'),
        findsNothing,
      );
    });

    testWidgets('should close dialog when agree button tapped', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocationPermissionAlertDialog.show(
                    context: context,
                    onAgree: () {},
                    onCancel: () {},
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('동의'), findsOneWidget);

      await tester.tap(find.text('동의'));
      await tester.pumpAndSettle();

      expect(
        find.text('젤로마크는 위치 기반 서비스이므로 위치 정보 제공에 동의가 꼭 필요해요'),
        findsNothing,
      );
    });

    testWidgets('should display location icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocationPermissionAlertDialog.show(
                    context: context,
                    onAgree: () {},
                    onCancel: () {},
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });
  });
}
