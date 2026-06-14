import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

const String _kLoginRequiredTitle = '로그인이 필요해요';
const String _kLoginRequiredDescription = '이 기능을 사용하려면 로그인해 주세요.';
const String _kKakaoButtonLabel = '카카오로 시작하기';
const String _kAppleButtonLabel = 'Apple로 시작하기';

Future<bool> ensureLoggedIn(
  BuildContext context,
  WidgetRef ref, {
  String? description,
}) async {
  final authRepository = sl<AuthRepository>();
  final tokens = await authRepository.getStoredTokens();
  if (tokens != null) {
    final memberResult = await authRepository.getCurrentMember();
    if (memberResult.isRight()) {
      return true;
    }
    await authRepository.clearStoredTokens();
  }

  if (!context.mounted) return false;

  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => _GuestLoginPromptSheet(
          description: description ?? _kLoginRequiredDescription,
        ),
      ) ??
      false;
}

class _GuestLoginPromptSheet extends ConsumerWidget {
  final String description;

  const _GuestLoginPromptSheet({required this.description});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: SemanticColors.state.error,
          ),
        );
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SemanticColors.text.disabled,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _kLoginRequiredTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: SemanticColors.text.secondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildKakaoButton(context, ref, isLoading),
          const SizedBox(height: 12),
          if (Platform.isIOS) _buildAppleButton(context, ref, isLoading),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
            child: Text(
              '닫기',
              style: TextStyle(color: SemanticColors.text.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKakaoButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                final success = await ref
                    .read(authNotifierProvider.notifier)
                    .loginWithKakao();
                if (success && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: SemanticColors.button.kakao,
          foregroundColor: SemanticColors.button.kakaoText,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                _kKakaoButtonLabel,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildAppleButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                final success = await ref
                    .read(authNotifierProvider.notifier)
                    .loginWithApple();
                if (success && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apple, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              _kAppleButtonLabel,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
