import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/domain/repositories/location_setting_repository.dart';
import 'package:jellomark/features/location/presentation/providers/location_permission_alert_provider.dart';
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

  group('LocationPermissionAlertNotifier', () {
    test('should return false initially for hasShownThisSession', () async {
      when(() => mockSettingRepository.isLocationEnabled())
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

      final notifier = container.read(locationPermissionAlertProvider.notifier);

      expect(notifier.hasShownThisSession, isFalse);
    });

    test('should return true for shouldShowAlert when permission denied', () async {
      when(() => mockSettingRepository.isLocationEnabled())
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

      final notifier = container.read(locationPermissionAlertProvider.notifier);
      final shouldShow = await notifier.shouldShowAlert();

      expect(shouldShow, isTrue);
    });

    test('should return false for shouldShowAlert when permission granted', () async {
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

      final notifier = container.read(locationPermissionAlertProvider.notifier);
      final shouldShow = await notifier.shouldShowAlert();

      expect(shouldShow, isFalse);
    });

    test('should return false for shouldShowAlert after markAsShown called', () async {
      when(() => mockSettingRepository.isLocationEnabled())
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

      final notifier = container.read(locationPermissionAlertProvider.notifier);
      notifier.markAsShown();
      final shouldShow = await notifier.shouldShowAlert();

      expect(shouldShow, isFalse);
    });

    test('should return true for shouldShowAlert when permission deniedForever', () async {
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

      final notifier = container.read(locationPermissionAlertProvider.notifier);
      final shouldShow = await notifier.shouldShowAlert();

      expect(shouldShow, isTrue);
    });
  });
}
