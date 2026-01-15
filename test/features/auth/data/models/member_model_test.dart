import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/auth/data/models/member_model.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

void main() {
  group('MemberModel', () {
    test('should be a subclass of Member entity', () {
      const model = MemberModel(
        id: 'member-123',
        nickname: '젤리123456',
        displayName: '젤리',
        socialProvider: 'KAKAO',
        socialId: '1234567890',
      );

      expect(model, isA<Member>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final json = {
          'id': 'member-456',
          'nickname': '마크654321',
          'displayName': '마크',
          'socialProvider': 'KAKAO',
          'socialId': '9876543210',
        };

        final result = MemberModel.fromJson(json);

        expect(result.id, 'member-456');
        expect(result.nickname, '마크654321');
        expect(result.displayName, '마크');
        expect(result.socialProvider, 'KAKAO');
        expect(result.socialId, '9876543210');
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        const model = MemberModel(
          id: 'member-789',
          nickname: '테스트111111',
          displayName: '테스트',
          socialProvider: 'KAKAO',
          socialId: '1111111111',
        );

        final result = model.toJson();

        expect(result['id'], 'member-789');
        expect(result['nickname'], '테스트111111');
        expect(result['displayName'], '테스트');
        expect(result['socialProvider'], 'KAKAO');
        expect(result['socialId'], '1111111111');
      });
    });
  });
}
