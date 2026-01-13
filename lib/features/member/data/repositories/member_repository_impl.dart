import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/member/data/datasources/member_remote_datasource.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberRepositoryImpl({required MemberRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Member>> updateProfile({
    required String nickname,
  }) async {
    try {
      final member = await _remoteDataSource.updateProfile(nickname: nickname);
      return Right(member);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return const Left(ValidationFailure('유효하지 않은 닉네임입니다'));
      }
      return Left(ServerFailure(_getErrorMessage(e)));
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      return (e.response?.data as Map)['error']?.toString() ?? '알 수 없는 오류';
    }
    return e.message ?? '알 수 없는 오류';
  }
}
