import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _authRepository;

  CheckAuthStatusUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Either<Failure, Member>> call() async {
    final tokens = await _authRepository.getStoredTokens();
    if (tokens == null) {
      return const Left(NoTokenFailure());
    }

    final memberResult = await _authRepository.getCurrentMember();
    if (memberResult.isRight()) {
      return memberResult;
    }

    final refreshResult = await _authRepository.refreshToken(
      tokens.refreshToken,
    );
    if (refreshResult.isLeft()) {
      await _authRepository.clearStoredTokens();
      return Left(
        refreshResult.fold(
          (f) => f,
          (_) => const AuthFailure('토큰 갱신에 실패했습니다'),
        ),
      );
    }

    final retryResult = await _authRepository.getCurrentMember();
    if (retryResult.isLeft()) {
      await _authRepository.clearStoredTokens();
    }
    return retryResult;
  }
}
