import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class CheckAuthStatusUseCase {
  final AuthLocalDataSource _localDataSource;
  final AuthRepository _authRepository;

  CheckAuthStatusUseCase({
    required AuthLocalDataSource localDataSource,
    required AuthRepository authRepository,
  }) : _localDataSource = localDataSource,
       _authRepository = authRepository;

  Future<Either<Failure, Member>> call() async {
    final tokens = await _localDataSource.getTokens();
    if (tokens == null) {
      return const Left(NoTokenFailure());
    }

    final memberResult = await _authRepository.getCurrentMember();

    return memberResult.fold((failure) async {
      final refreshResult = await _authRepository.refreshToken(
        tokens.refreshToken,
      );

      return refreshResult.fold(
        (refreshFailure) {
          _localDataSource.clearTokens();
          return Left(refreshFailure);
        },
        (_) async {
          final retryResult = await _authRepository.getCurrentMember();
          return retryResult.fold(
            (retryFailure) {
              _localDataSource.clearTokens();
              return Left(retryFailure);
            },
            (member) => Right(member),
          );
        },
      );
    }, (member) => Right(member));
  }
}
