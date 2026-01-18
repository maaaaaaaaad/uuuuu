import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/domain/repositories/location_setting_repository.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
import 'package:jellomark/features/location/presentation/widgets/location_setting_toggle.dart';
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
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        locationSettingRepositoryProvider
            .overrideWithValue(mockSettingRepository),
        locationRepositoryForSettingProvider
            .overrideWithValue(mockLocationRepository),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: LocationSettingToggle(),
        ),
      ),
    );
  }

  group('LocationSettingToggle', () {
    testWidgets('should display toggle with label', (tester) async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => true);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.granted);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('위치 정보 사용'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should show toggle ON when setting is enabled', (tester) async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => true);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.granted);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('should show toggle OFF when setting is disabled', (tester) async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.denied);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('should call toggle when switch is tapped', (tester) async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => true);
      when(() => mockSettingRepository.setLocationEnabled(false))
          .thenAnswer((_) async {});
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.granted);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      verify(() => mockSettingRepository.setLocationEnabled(false)).called(1);
    });

    testWidgets('should show loading indicator while loading', (tester) async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) => Future.value(true));
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) => Future.value(LocationPermissionResult.granted));

      await tester.pumpWidget(createWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should request permission when enabling and permission is denied',
        (tester) async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.denied);
      when(() => mockLocationRepository.requestLocationPermission())
          .thenAnswer((_) async => const Right(true));
      when(() => mockSettingRepository.setLocationEnabled(true))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      verify(() => mockLocationRepository.requestLocationPermission()).called(1);
    });
  });
}
