import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/domain/repositories/location_setting_repository.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
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

  group('locationSettingProvider', () {
    test('should return true when setting is enabled', () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => true);

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(locationSettingProvider.future);

      expect(result, isTrue);
    });

    test('should return false when setting is disabled', () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(locationSettingProvider.future);

      expect(result, isFalse);
    });
  });

  group('locationSettingNotifierProvider', () {
    test('should initialize with current setting', () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => true);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.granted);

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      final state =
          container.read(locationSettingNotifierProvider).requireValue;

      expect(state.isEnabled, isTrue);
    });

    test('should update setting when toggle is called', () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => true);
      when(() => mockSettingRepository.setLocationEnabled(false))
          .thenAnswer((_) async {});
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.granted);

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      await container.read(locationSettingNotifierProvider.notifier).toggle();

      verify(() => mockSettingRepository.setLocationEnabled(false)).called(1);
    });

    test('should request permission when enabling and permission is denied',
        () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.denied);
      when(() => mockLocationRepository.requestLocationPermission())
          .thenAnswer((_) async => const Right(true));
      when(() => mockSettingRepository.setLocationEnabled(true))
          .thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      await container.read(locationSettingNotifierProvider.notifier).toggle();

      verify(() => mockLocationRepository.requestLocationPermission()).called(1);
    });

    test(
        'should return deniedForever result when permission is denied forever',
        () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.deniedForever);

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      final result =
          await container.read(locationSettingNotifierProvider.notifier).toggle();

      expect(result, LocationSettingToggleResult.deniedForever);
    });
  });

  group('requestPermissionAndEnable', () {
    test('should return serviceDisabled when location service is disabled',
        () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.isLocationServiceEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.denied);

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      final result = await container
          .read(locationSettingNotifierProvider.notifier)
          .requestPermissionAndEnable();

      expect(result, LocationSettingToggleResult.serviceDisabled);
    });

    test('should enable when permission is already granted', () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.granted);
      when(() => mockSettingRepository.setLocationEnabled(true))
          .thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      final result = await container
          .read(locationSettingNotifierProvider.notifier)
          .requestPermissionAndEnable();

      expect(result, LocationSettingToggleResult.success);
      verify(() => mockSettingRepository.setLocationEnabled(true)).called(1);
    });

    test('should return deniedForever when permission is denied forever',
        () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.deniedForever);
      when(() => mockLocationRepository.requestLocationPermission())
          .thenAnswer((_) async => const Right(false));

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      final result = await container
          .read(locationSettingNotifierProvider.notifier)
          .requestPermissionAndEnable();

      expect(result, LocationSettingToggleResult.deniedForever);
    });

    test('should request permission and enable when denied', () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.denied);
      when(() => mockLocationRepository.requestLocationPermission())
          .thenAnswer((_) async => const Right(true));
      when(() => mockSettingRepository.setLocationEnabled(true))
          .thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      final result = await container
          .read(locationSettingNotifierProvider.notifier)
          .requestPermissionAndEnable();

      expect(result, LocationSettingToggleResult.success);
      verify(() => mockLocationRepository.requestLocationPermission()).called(1);
      verify(() => mockSettingRepository.setLocationEnabled(true)).called(1);
    });

    test('should return denied when permission request is not granted',
        () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockLocationRepository.checkPermissionStatus())
          .thenAnswer((_) async => LocationPermissionResult.denied);
      when(() => mockLocationRepository.requestLocationPermission())
          .thenAnswer((_) async => const Right(false));

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      final result = await container
          .read(locationSettingNotifierProvider.notifier)
          .requestPermissionAndEnable();

      expect(result, LocationSettingToggleResult.denied);
    });

    test(
        'should return deniedForever when permission becomes deniedForever after request',
        () async {
      when(() => mockSettingRepository.isLocationEnabled())
          .thenAnswer((_) async => false);
      when(() => mockLocationRepository.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      int callCount = 0;
      when(() => mockLocationRepository.checkPermissionStatus()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return LocationPermissionResult.denied;
        }
        return LocationPermissionResult.deniedForever;
      });
      when(() => mockLocationRepository.requestLocationPermission())
          .thenAnswer((_) async => const Right(false));

      final container = ProviderContainer(
        overrides: [
          locationSettingRepositoryProvider
              .overrideWithValue(mockSettingRepository),
          locationRepositoryForSettingProvider
              .overrideWithValue(mockLocationRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(locationSettingNotifierProvider.future);
      final result = await container
          .read(locationSettingNotifierProvider.notifier)
          .requestPermissionAndEnable();

      expect(result, LocationSettingToggleResult.deniedForever);
    });
  });
}
