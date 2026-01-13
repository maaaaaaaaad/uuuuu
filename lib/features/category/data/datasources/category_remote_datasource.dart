import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/category/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get('/api/categories');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
