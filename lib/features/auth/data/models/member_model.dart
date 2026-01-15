import 'package:jellomark/features/member/domain/entities/member.dart';

class MemberModel extends Member {
  const MemberModel({
    required super.id,
    required super.nickname,
    required super.displayName,
    required super.socialProvider,
    required super.socialId,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      displayName: json['displayName'] as String,
      socialProvider: json['socialProvider'] as String,
      socialId: json['socialId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'displayName': displayName,
      'socialProvider': socialProvider,
      'socialId': socialId,
    };
  }
}
