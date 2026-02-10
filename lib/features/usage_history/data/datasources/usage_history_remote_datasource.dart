import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/usage_history/data/models/usage_history_model.dart';

abstract class UsageHistoryRemoteDataSource {
  Future<List<UsageHistoryModel>> getMyUsageHistory();
}

class UsageHistoryRemoteDataSourceImpl implements UsageHistoryRemoteDataSource {
  final ApiClient apiClient;

  UsageHistoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<UsageHistoryModel>> getMyUsageHistory() async {
    final response = await apiClient.get<List<dynamic>>('/api/usage-history/me');
    return response.data!
        .map((json) => UsageHistoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
