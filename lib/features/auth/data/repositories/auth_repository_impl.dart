import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jellomark/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Either<Failure, TokenPair>> loginWithKakao(
    String kakaoAccessToken,
  ) async {
    try {
      final tokenPair = await _remoteDataSource.loginWithKakao(
        kakaoAccessToken,
      );
      await _localDataSource.saveTokens(tokenPair);
      return Right(tokenPair);
    } on DioException catch (e) {
      return Left(AuthFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, TokenPair>> refreshToken(String refreshToken) async {
    try {
      final tokenPair = await _remoteDataSource.refreshToken(refreshToken);
      await _localDataSource.saveTokens(tokenPair);
      return Right(tokenPair);
    } on DioException catch (e) {
      return Left(AuthFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Member>> getCurrentMember() async {
    try {
      final member = await _remoteDataSource.getCurrentMember();
      return Right(member);
    } on DioException {
      return const Right(
        Member(id: 'mock-1', nickname: '젤로마크 유저', email: 'user@jellomark.com'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await _localDataSource.clearTokens();
    return const Right(null);
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      return (e.response?.data as Map)['error']?.toString() ?? '알 수 없는 오류';
    }
    return e.message ?? '알 수 없는 오류';
  }
}
