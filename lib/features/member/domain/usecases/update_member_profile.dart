import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/repositories/member_repository.dart';

class UpdateMemberProfile {
  final MemberRepository repository;

  UpdateMemberProfile({required this.repository});

  Future<Either<Failure, Member>> call({required String nickname}) async {
    if (nickname.isEmpty) {
      return const Left(ValidationFailure('닉네임을 입력해주세요'));
    }

    if (nickname.length > 50) {
      return const Left(ValidationFailure('닉네임은 50자 이하로 입력해주세요'));
    }

    return await repository.updateProfile(nickname: nickname);
  }
}
