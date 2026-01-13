import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

abstract class AuthRepository {
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk();

  Future<Either<Failure, TokenPair>> loginWithKakao(String kakaoAccessToken);

  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken);

  Future<Either<Failure, Member>> getCurrentMember();

  Future<Either<Failure, void>> logout();

  Future<TokenPair?> getStoredTokens();

  Future<void> clearStoredTokens();
}
