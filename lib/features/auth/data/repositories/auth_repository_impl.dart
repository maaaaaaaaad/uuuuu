import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jellomark/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final KakaoAuthService _kakaoAuthService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required KakaoAuthService kakaoAuthService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _kakaoAuthService = kakaoAuthService;

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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure('인증이 만료되었습니다'));
      }
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _kakaoAuthService.logout();
    } catch (_) {}
    try {
      await _remoteDataSource.logout();
    } catch (_) {}
    await _localDataSource.clearTokens();
    return const Right(null);
  }

  @override
  Future<Either<Failure, TokenPair>> loginWithKakaoSdk() async {
    try {
      final kakaoAccessToken = await _kakaoAuthService.loginWithKakao();
      return await loginWithKakao(kakaoAccessToken);
    } catch (e) {
      return Left(KakaoLoginFailure(e.toString()));
    }
  }

  @override
  Future<TokenPair?> getStoredTokens() async {
    return await _localDataSource.getTokens();
  }

  @override
  Future<void> clearStoredTokens() async {
    await _localDataSource.clearTokens();
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      return (e.response?.data as Map)['error']?.toString() ?? '알 수 없는 오류';
    }
    return e.message ?? '알 수 없는 오류';
  }
}
