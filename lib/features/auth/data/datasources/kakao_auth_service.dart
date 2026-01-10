import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 로그인 서비스 추상화 (테스트 가능하도록)
abstract class KakaoAuthService {
  /// 카카오 로그인을 수행하고 카카오 액세스 토큰을 반환
  Future<String> loginWithKakao();

  /// 카카오 로그아웃
  Future<void> logout();
}

/// 카카오 SDK를 직접 사용하는 구현체
class KakaoAuthServiceImpl implements KakaoAuthService {
  @override
  Future<String> loginWithKakao() async {
    OAuthToken token;

    // 카카오톡 설치 여부 확인
    if (await isKakaoTalkInstalled()) {
      token = await UserApi.instance.loginWithKakaoTalk();
    } else {
      token = await UserApi.instance.loginWithKakaoAccount();
    }

    return token.accessToken;
  }

  @override
  Future<void> logout() async {
    await UserApi.instance.logout();
  }
}
