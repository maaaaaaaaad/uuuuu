import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/auth/data/models/token_pair_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenPairModel> loginWithKakao(String kakaoAccessToken);

  Future<TokenPairModel> refreshToken(String refreshToken);

  Future<MemberModel> getCurrentMember();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<TokenPairModel> loginWithKakao(String kakaoAccessToken) async {
    final response = await _apiClient.post(
      '/api/auth/kakao',
      data: {'kakaoAccessToken': kakaoAccessToken},
    );
    return TokenPairModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TokenPairModel> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return TokenPairModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MemberModel> getCurrentMember() async {
    final response = await _apiClient.get('/api/members/me');
    return MemberModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post('/api/auth/logout');
  }
}
