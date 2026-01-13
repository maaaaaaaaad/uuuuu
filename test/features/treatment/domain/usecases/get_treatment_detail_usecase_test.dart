import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/treatment/domain/repositories/treatment_repository.dart';
import 'package:jellomark/features/treatment/domain/usecases/get_treatment_detail_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockTreatmentRepository extends Mock implements TreatmentRepository {}

void main() {
  late GetTreatmentDetailUseCase useCase;
  late MockTreatmentRepository mockRepository;

  setUp(() {
    mockRepository = MockTreatmentRepository();
    useCase = GetTreatmentDetailUseCase(repository: mockRepository);
  });

  const testTreatment = ServiceMenu(
    id: '1',
    name: '젤네일 풀세트',
    price: 50000,
    durationMinutes: 90,
    description: '고급 젤네일 풀세트',
  );

  group('GetTreatmentDetailUseCase', () {
    test('returns ServiceMenu from repository', () async {
      when(() => mockRepository.getTreatmentById(any()))
          .thenAnswer((_) async => const Right(testTreatment));

      final result = await useCase(treatmentId: '1');

      expect(result, isA<Right<Failure, ServiceMenu>>());
      final treatment = (result as Right).value as ServiceMenu;
      expect(treatment.name, equals('젤네일 풀세트'));
      expect(treatment.price, equals(50000));
      verify(() => mockRepository.getTreatmentById('1')).called(1);
    });

    test('returns failure when treatment not found', () async {
      when(() => mockRepository.getTreatmentById(any()))
          .thenAnswer((_) async => const Left(ServerFailure('시술을 찾을 수 없습니다')));

      final result = await useCase(treatmentId: 'non-existent');

      expect(result, isA<Left<Failure, ServiceMenu>>());
      final failure = (result as Left).value as Failure;
      expect(failure, isA<ServerFailure>());
      verify(() => mockRepository.getTreatmentById('non-existent')).called(1);
    });
  });
}
