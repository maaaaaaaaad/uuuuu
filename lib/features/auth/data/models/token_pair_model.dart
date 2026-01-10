import 'package:jellomark/features/auth/domain/entities/token_pair.dart';

class TokenPairModel extends TokenPair {
  const TokenPairModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory TokenPairModel.fromJson(Map<String, dynamic> json) {
    return TokenPairModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }
}
