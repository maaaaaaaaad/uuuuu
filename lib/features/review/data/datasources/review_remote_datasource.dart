import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/review/data/models/paged_reviews_model.dart';
import 'package:jellomark/features/review/data/models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<PagedReviewsModel> getShopReviews({
    required String shopId,
    required int page,
    required int size,
  });

  Future<PagedReviewsModel> getMyReviews({
    required int page,
    required int size,
  });

  Future<ReviewModel> createReview({
    required String shopId,
    int? rating,
    String? content,
    List<String>? images,
  });

  Future<ReviewModel> updateReview({
    required String shopId,
    required String reviewId,
    int? rating,
    String? content,
    List<String>? images,
  });

  Future<void> deleteReview({
    required String shopId,
    required String reviewId,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient _apiClient;

  ReviewRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PagedReviewsModel> getShopReviews({
    required String shopId,
    required int page,
    required int size,
  }) async {
    final response = await _apiClient.get(
      '/api/beautishops/$shopId/reviews',
      queryParameters: {'page': page, 'size': size},
    );

    return PagedReviewsModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PagedReviewsModel> getMyReviews({
    required int page,
    required int size,
  }) async {
    final response = await _apiClient.get(
      '/api/reviews/me',
      queryParameters: {'page': page, 'size': size},
    );

    return PagedReviewsModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ReviewModel> createReview({
    required String shopId,
    int? rating,
    String? content,
    List<String>? images,
  }) async {
    final data = <String, dynamic>{};
    if (rating != null) data['rating'] = rating;
    if (content != null) data['content'] = content;
    if (images != null) data['images'] = images;

    final response = await _apiClient.post(
      '/api/beautishops/$shopId/reviews',
      data: data,
    );

    return ReviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ReviewModel> updateReview({
    required String shopId,
    required String reviewId,
    int? rating,
    String? content,
    List<String>? images,
  }) async {
    final data = <String, dynamic>{};
    if (rating != null) data['rating'] = rating;
    if (content != null) data['content'] = content;
    if (images != null) data['images'] = images;

    final response = await _apiClient.put(
      '/api/beautishops/$shopId/reviews/$reviewId',
      data: data,
    );

    return ReviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteReview({
    required String shopId,
    required String reviewId,
  }) async {
    await _apiClient.delete('/api/beautishops/$shopId/reviews/$reviewId');
  }
}
