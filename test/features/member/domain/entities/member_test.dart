import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

void main() {
  group('Member', () {
    test('should create Member with required fields', () {
      final member = Member(
        id: 'member-123',
        nickname: '젤리',
        email: 'jelly@example.com',
      );

      expect(member.id, 'member-123');
      expect(member.nickname, '젤리');
      expect(member.email, 'jelly@example.com');
    });

    test('should support value equality', () {
      final member1 = Member(
        id: 'member-123',
        nickname: '젤리',
        email: 'jelly@example.com',
      );

      final member2 = Member(
        id: 'member-123',
        nickname: '젤리',
        email: 'jelly@example.com',
      );

      expect(member1, equals(member2));
    });

    test('should have different hashCode for different members', () {
      final member1 = Member(
        id: 'member-123',
        nickname: '젤리',
        email: 'jelly@example.com',
      );

      final member2 = Member(
        id: 'member-456',
        nickname: '마크',
        email: 'mark@example.com',
      );

      expect(member1.hashCode, isNot(equals(member2.hashCode)));
    });
  });
}
