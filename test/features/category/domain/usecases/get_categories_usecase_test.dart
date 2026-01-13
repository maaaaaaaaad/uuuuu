import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:jellomark/features/category/domain/repositories/category_repository.dart';
import 'package:jellomark/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  group('GetCategoriesUseCase', () {
    late GetCategoriesUseCase useCase;
    late MockCategoryRepository mockRepository;

    setUp(() {
      mockRepository = MockCategoryRepository();
      useCase = GetCategoriesUseCase(repository: mockRepository);
    });

    test('returns categories from repository', () async {
      const categories = [
        Category(id: 'cat-1', name: '헤어'),
        Category(id: 'cat-2', name: '네일'),
      ];

      when(() => mockRepository.getCategories())
          .thenAnswer((_) async => const Right(categories));

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cats) {
          expect(cats.length, equals(2));
          expect(cats[0].name, equals('헤어'));
        },
      );

      verify(() => mockRepository.getCategories()).called(1);
    });

    test('returns failure from repository', () async {
      when(() => mockRepository.getCategories())
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (cats) => fail('Should not return success'),
      );
    });
  });
}
