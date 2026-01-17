import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/domain/usecases/get_current_location_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late GetCurrentLocationUseCase useCase;
  late MockLocationRepository mockRepository;

  setUp(() {
    mockRepository = MockLocationRepository();
    useCase = GetCurrentLocationUseCase(mockRepository);
  });

  const tUserLocation = UserLocation(
    latitude: 37.5665,
    longitude: 126.9780,
  );

  group('GetCurrentLocationUseCase', () {
    test('should get current location from the repository', () async {
      when(() => mockRepository.getCurrentLocation())
          .thenAnswer((_) async => const Right(tUserLocation));

      final result = await useCase();

      expect(result, const Right(tUserLocation));
      verify(() => mockRepository.getCurrentLocation()).called(1);
    });

    test('should return failure when repository fails', () async {
      when(() => mockRepository.getCurrentLocation()).thenAnswer(
        (_) async => const Left(LocationPermissionDeniedFailure()),
      );

      final result = await useCase();

      expect(result, isA<Left>());
      verify(() => mockRepository.getCurrentLocation()).called(1);
    });

    test('should return LocationServiceDisabledFailure when service disabled',
        () async {
      when(() => mockRepository.getCurrentLocation()).thenAnswer(
        (_) async => const Left(LocationServiceDisabledFailure()),
      );

      final result = await useCase();

      result.fold(
        (failure) => expect(failure, isA<LocationServiceDisabledFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
