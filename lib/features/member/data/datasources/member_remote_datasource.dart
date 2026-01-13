import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';

abstract class MemberRemoteDataSource {
  Future<MemberModel> updateProfile({required String nickname});
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  final ApiClient _apiClient;

  MemberRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<MemberModel> updateProfile({required String nickname}) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/api/members/me',
      data: {'nickname': nickname},
    );
    return MemberModel.fromJson(response.data!);
  }
}
