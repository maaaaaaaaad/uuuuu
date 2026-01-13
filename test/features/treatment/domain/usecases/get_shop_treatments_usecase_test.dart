import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/treatment/domain/repositories/treatment_repository.dart';
import 'package:jellomark/features/treatment/domain/usecases/get_shop_treatments_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockTreatmentRepository extends Mock implements TreatmentRepository {}

void main() {
  late GetShopTreatmentsUseCase useCase;
  late MockTreatmentRepository mockRepository;

  setUp(() {
    mockRepository = MockTreatmentRepository();
    useCase = GetShopTreatmentsUseCase(repository: mockRepository);
  });

  const testTreatments = [
    ServiceMenu(
      id: '1',
      name: '젤네일 풀세트',
      price: 50000,
      durationMinutes: 90,
      description: '고급 젤네일 풀세트',
    ),
    ServiceMenu(
      id: '2',
      name: '손톱 케어',
      price: 20000,
      durationMinutes: 30,
    ),
  ];

  group('GetShopTreatmentsUseCase', () {
    test('returns list of ServiceMenu from repository', () async {
      when(() => mockRepository.getShopTreatments(any()))
          .thenAnswer((_) async => const Right(testTreatments));

      final result = await useCase(shopId: 'shop-1');

      expect(result, isA<Right<Failure, List<ServiceMenu>>>());
      final treatments = (result as Right).value as List<ServiceMenu>;
      expect(treatments.length, equals(2));
      expect(treatments.first.name, equals('젤네일 풀세트'));
      verify(() => mockRepository.getShopTreatments('shop-1')).called(1);
    });

    test('returns failure when repository fails', () async {
      when(() => mockRepository.getShopTreatments(any()))
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final result = await useCase(shopId: 'shop-1');

      expect(result, isA<Left<Failure, List<ServiceMenu>>>());
      verify(() => mockRepository.getShopTreatments('shop-1')).called(1);
    });

    test('returns empty list when shop has no treatments', () async {
      when(() => mockRepository.getShopTreatments(any()))
          .thenAnswer((_) async => const Right([]));

      final result = await useCase(shopId: 'shop-1');

      expect(result, isA<Right<Failure, List<ServiceMenu>>>());
      final treatments = (result as Right).value as List<ServiceMenu>;
      expect(treatments, isEmpty);
    });
  });
}
