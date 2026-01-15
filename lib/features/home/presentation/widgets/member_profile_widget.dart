import 'package:flutter/material.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class MemberProfileWidget extends StatelessWidget {
  final Member member;

  const MemberProfileWidget({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          child: Text(
            member.displayName.isNotEmpty ? member.displayName[0] : '?',
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              member.displayName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '${member.socialProvider}로 로그인',
              style: TextStyle(fontSize: 14, color: SemanticColors.text.secondary),
            ),
          ],
        ),
      ],
    );
  }
}
