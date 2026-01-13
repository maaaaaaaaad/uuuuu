import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
}
