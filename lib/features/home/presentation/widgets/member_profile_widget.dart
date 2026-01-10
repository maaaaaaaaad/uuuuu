import 'package:flutter/material.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class MemberProfileWidget extends StatelessWidget {
  final Member member;

  const MemberProfileWidget({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          child: Text(member.nickname.isNotEmpty ? member.nickname[0] : '?'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              member.nickname,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              member.email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
