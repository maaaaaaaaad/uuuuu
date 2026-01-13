import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/usecases/get_current_member.dart';

final getCurrentMemberUseCaseProvider = Provider<GetCurrentMember>((ref) {
  return sl<GetCurrentMember>();
});

final currentMemberProvider = FutureProvider<Member>((ref) async {
  final useCase = ref.watch(getCurrentMemberUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (member) => member,
  );
});
