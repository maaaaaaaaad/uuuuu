import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/data/datasources/review_remote_datasource.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PagedReviews>> getShopReviews({
    required String shopId,
    required int page,
    required int size,
  }) async {
    try {
      final result = await remoteDataSource.getShopReviews(
        shopId: shopId,
        page: page,
        size: size,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, Review>> createReview({
    required String shopId,
    int? rating,
    String? content,
    List<String>? images,
  }) async {
    try {
      final result = await remoteDataSource.createReview(
        shopId: shopId,
        rating: rating,
        content: content,
        images: images,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, Review>> updateReview({
    required String shopId,
    required String reviewId,
    int? rating,
    String? content,
    List<String>? images,
  }) async {
    try {
      final result = await remoteDataSource.updateReview(
        shopId: shopId,
        reviewId: reviewId,
        rating: rating,
        content: content,
        images: images,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview({
    required String shopId,
    required String reviewId,
  }) async {
    try {
      await remoteDataSource.deleteReview(
        shopId: shopId,
        reviewId: reviewId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }
}
