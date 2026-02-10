import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/notification/domain/repositories/device_token_repository.dart';
import 'package:jellomark/features/notification/domain/usecases/register_device_token_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceTokenRepository extends Mock implements DeviceTokenRepository {}

void main() {
  late RegisterDeviceTokenUseCase useCase;
  late MockDeviceTokenRepository mockRepository;

  setUp(() {
    mockRepository = MockDeviceTokenRepository();
    useCase = RegisterDeviceTokenUseCase(repository: mockRepository);
  });

  test('should delegate to repository', () async {
    when(() => mockRepository.registerToken('token', 'IOS'))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase('token', 'IOS');

    expect(result, const Right(null));
    verify(() => mockRepository.registerToken('token', 'IOS')).called(1);
  });

  test('should return failure from repository', () async {
    when(() => mockRepository.registerToken('token', 'ANDROID'))
        .thenAnswer((_) async => const Left(ServerFailure('실패')));

    final result = await useCase('token', 'ANDROID');

    expect(result.isLeft(), true);
  });
}
