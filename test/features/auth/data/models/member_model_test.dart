import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

void main() {
  group('MemberModel', () {
    test('should be a subclass of Member entity', () {
      const model = MemberModel(
        id: 'member-123',
        nickname: '젤리',
        email: 'jelly@example.com',
      );

      expect(model, isA<Member>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final json = {
          'id': 'member-456',
          'nickname': '마크',
          'email': 'mark@example.com',
        };

        final result = MemberModel.fromJson(json);

        expect(result.id, 'member-456');
        expect(result.nickname, '마크');
        expect(result.email, 'mark@example.com');
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        const model = MemberModel(
          id: 'member-789',
          nickname: '테스트',
          email: 'test@example.com',
        );

        final result = model.toJson();

        expect(result['id'], 'member-789');
        expect(result['nickname'], '테스트');
        expect(result['email'], 'test@example.com');
      });
    });
  });
}
