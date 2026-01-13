import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:jellomark/features/category/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository _repository;

  GetCategoriesUseCase({required CategoryRepository repository})
    : _repository = repository;

  Future<Either<Failure, List<Category>>> call() {
    return _repository.getCategories();
  }
}
