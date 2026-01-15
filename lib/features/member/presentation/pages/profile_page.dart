import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:jellomark/features/member/presentation/providers/member_providers.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/widgets/gradient_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final logoutUseCase = ref.read(logoutUseCaseProvider);
    await logoutUseCase();

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(currentMemberProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('프로필'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: SemanticColors.special.transparent,
        foregroundColor: SemanticColors.text.primary,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: SemanticColors.special.transparent),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: SafeArea(
          child: memberAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(
                color: SemanticColors.indicator.loading,
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SemanticColors.background.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: SemanticColors.icon.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '오류가 발생했습니다',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            data: (member) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GradientCard(
                    gradientType: GradientType.mint,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: SemanticColors.text.onDark,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: SemanticColors.overlay.avatarShadow,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: SemanticColors.background.input,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: SemanticColors.icon.accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          member.displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: SemanticColors.text.onDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${member.socialProvider}로 로그인',
                          style: TextStyle(
                            fontSize: 14,
                            color: SemanticColors.text.onDarkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _handleLogout(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SemanticColors.button.outlineText,
                        side: BorderSide(color: SemanticColors.button.outlineBorder),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('로그아웃'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
