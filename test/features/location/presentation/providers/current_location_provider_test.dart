import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/domain/repositories/location_setting_repository.dart';
import 'package:jellomark/features/location/domain/usecases/get_current_location_usecase.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentLocationUseCase extends Mock
    implements GetCurrentLocationUseCase {}

class _FakeSettingRepository implements LocationSettingRepository {
  _FakeSettingRepository(this.enabled);
  final bool enabled;

  @override
  Future<bool> isLocationEnabled() async => enabled;

  @override
  Future<void> setLocationEnabled(bool value) async {}
}

void main() {
  late MockGetCurrentLocationUseCase useCase;

  setUp(() => useCase = MockGetCurrentLocationUseCase());

  ProviderContainer makeContainer({required bool enabled}) {
    return ProviderContainer(
      overrides: [
        getCurrentLocationUseCaseProvider.overrideWithValue(useCase),
        locationSettingRepositoryProvider.overrideWithValue(
          _FakeSettingRepository(enabled),
        ),
      ],
    );
  }

  group('currentLocationProvider', () {
    test('returns null and skips fetch when location setting is OFF', () async {
      final container = makeContainer(enabled: false);

      final result = await container.read(currentLocationProvider.future);

      expect(result, isNull);
      verifyNever(() => useCase());
    });

    test('fetches and returns location when setting is ON', () async {
      when(() => useCase()).thenAnswer(
        (_) async => const Right(UserLocation(latitude: 37.5, longitude: 127.0)),
      );
      final container = makeContainer(enabled: true);

      final result = await container.read(currentLocationProvider.future);

      expect(result, const UserLocation(latitude: 37.5, longitude: 127.0));
      verify(() => useCase()).called(1);
    });

    test('returns null when the fetch itself fails', () async {
      when(() => useCase()).thenAnswer(
        (_) async => const Left(LocationFailure('실패')),
      );
      final container = makeContainer(enabled: true);

      final result = await container.read(currentLocationProvider.future);

      expect(result, isNull);
    });
  });
}
