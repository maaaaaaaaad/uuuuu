import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

void main() {
  group('Member', () {
    test('should create Member with required fields', () {
      const member = Member(
        id: 'member-123',
        nickname: '젤리',
        socialProvider: 'KAKAO',
        socialId: '1234567890',
      );

      expect(member.id, 'member-123');
      expect(member.nickname, '젤리');
      expect(member.socialProvider, 'KAKAO');
      expect(member.socialId, '1234567890');
    });

    test('should support value equality', () {
      const member1 = Member(
        id: 'member-123',
        nickname: '젤리',
        socialProvider: 'KAKAO',
        socialId: '1234567890',
      );

      const member2 = Member(
        id: 'member-123',
        nickname: '젤리',
        socialProvider: 'KAKAO',
        socialId: '1234567890',
      );

      expect(member1, equals(member2));
    });

    test('should have different hashCode for different members', () {
      const member1 = Member(
        id: 'member-123',
        nickname: '젤리',
        socialProvider: 'KAKAO',
        socialId: '1234567890',
      );

      const member2 = Member(
        id: 'member-456',
        nickname: '마크',
        socialProvider: 'KAKAO',
        socialId: '9876543210',
      );

      expect(member1.hashCode, isNot(equals(member2.hashCode)));
    });
  });
}
