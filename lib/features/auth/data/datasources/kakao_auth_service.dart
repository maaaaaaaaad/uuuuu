import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

abstract class KakaoAuthService {
  Future<String> loginWithKakao();
  Future<void> logout();
}

class KakaoAuthServiceImpl implements KakaoAuthService {
  @override
  Future<String> loginWithKakao() async {
    OAuthToken token;

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
