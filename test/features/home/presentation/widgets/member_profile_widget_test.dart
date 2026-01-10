import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/home/presentation/widgets/member_profile_widget.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

void main() {
  group('MemberProfileWidget', () {
    const testMember = Member(
      id: 'member-123',
      nickname: '젤리',
      email: 'jelly@example.com',
    );

    testWidgets('should display member nickname', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MemberProfileWidget(member: testMember)),
        ),
      );

      expect(find.text('젤리'), findsOneWidget);
    });

    testWidgets('should display member email', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MemberProfileWidget(member: testMember)),
        ),
      );

      expect(find.text('jelly@example.com'), findsOneWidget);
    });

    testWidgets('should display profile avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MemberProfileWidget(member: testMember)),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}
