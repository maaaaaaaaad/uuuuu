import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/treatment/data/models/treatment_model.dart';

abstract class TreatmentRemoteDataSource {
  Future<List<TreatmentModel>> getShopTreatments(String shopId);

  Future<TreatmentModel> getTreatmentById(String treatmentId);
}

class TreatmentRemoteDataSourceImpl implements TreatmentRemoteDataSource {
  final ApiClient _apiClient;

  TreatmentRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<TreatmentModel>> getShopTreatments(String shopId) async {
    final response = await _apiClient.get('/api/beautishops/$shopId/treatments');

    final treatments = (response.data as List<dynamic>)
        .map((json) => TreatmentModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return treatments;
  }

  @override
  Future<TreatmentModel> getTreatmentById(String treatmentId) async {
    final response = await _apiClient.get('/api/treatments/$treatmentId');
    return TreatmentModel.fromJson(response.data as Map<String, dynamic>);
  }
}
