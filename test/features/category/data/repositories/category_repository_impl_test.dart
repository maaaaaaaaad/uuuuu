import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/category/data/datasources/category_remote_datasource.dart';
import 'package:jellomark/features/category/data/models/category_model.dart';
import 'package:jellomark/features/category/data/repositories/category_repository_impl.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

void main() {
  group('CategoryRepositoryImpl', () {
    late CategoryRepositoryImpl repository;
    late MockCategoryRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockCategoryRemoteDataSource();
      repository = CategoryRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    group('getCategories', () {
      test('returns Right(List<Category>) on success', () async {
        final categories = [
          const CategoryModel(id: 'cat-1', name: '헤어'),
          const CategoryModel(id: 'cat-2', name: '네일'),
        ];

        when(() => mockRemoteDataSource.getCategories())
            .thenAnswer((_) async => categories);

        final result = await repository.getCategories();

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (cats) {
            expect(cats, isA<List<Category>>());
            expect(cats.length, equals(2));
          },
        );
      });

      test('returns Left(ServerFailure) on DioException', () async {
        when(() => mockRemoteDataSource.getCategories()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/categories'),
            message: 'Server error',
          ),
        );

        final result = await repository.getCategories();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (cats) => fail('Should not return success'),
        );
      });
    });
  });
}
