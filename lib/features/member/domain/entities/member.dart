import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final String id;
  final String nickname;
  final String socialProvider;
  final String socialId;

  const Member({
    required this.id,
    required this.nickname,
    required this.socialProvider,
    required this.socialId,
  });

  @override
  List<Object?> get props => [id, nickname, socialProvider, socialId];
}
