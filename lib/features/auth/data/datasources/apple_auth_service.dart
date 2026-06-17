import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInResult {
  final String identityToken;
  final String? fullName;

  const AppleSignInResult({required this.identityToken, this.fullName});
}

abstract class AppleAuthService {
  Future<AppleSignInResult> loginWithApple();
}

class AppleAuthServiceImpl implements AppleAuthService {
  @override
  Future<AppleSignInResult> loginWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null || identityToken.isEmpty) {
      throw const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.invalidResponse,
        message: 'Apple identity token이 비어 있습니다',
      );
    }

    final composedName = [
      credential.givenName,
      credential.familyName,
    ].whereType<String>().where((p) => p.trim().isNotEmpty).join(' ').trim();

    return AppleSignInResult(
      identityToken: identityToken,
      fullName: composedName.isEmpty ? null : composedName,
    );
  }
}
