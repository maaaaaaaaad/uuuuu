import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildFloatingDecorations(),
              _buildMainContent(context, ref, isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 60,
          left: 30,
          child: _buildDecoration(Icons.star, 24, 0.3),
        ),
        Positioned(
          top: 120,
          right: 40,
          child: _buildDecoration(Icons.favorite, 20, 0.25),
        ),
        Positioned(
          top: 200,
          left: 50,
          child: _buildDecoration(Icons.cloud, 32, 0.2),
        ),
        Positioned(
          bottom: 200,
          right: 30,
          child: _buildDecoration(Icons.star, 18, 0.35),
        ),
        Positioned(
          bottom: 280,
          left: 40,
          child: _buildDecoration(Icons.favorite, 22, 0.2),
        ),
      ],
    );
  }

  Widget _buildDecoration(IconData icon, double size, double opacity) {
    return Icon(
      icon,
      size: size,
      color: SemanticColors.icon.accentPink.withValues(alpha: opacity),
    );
  }

  Widget _buildMainContent(BuildContext context, WidgetRef ref, bool isLoading) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1),
              Image.asset(
                'assets/splash/splash-jellomark01.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 24),
              Text(
                '젤로마크',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: SemanticColors.text.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '나만의 뷰티샵을 찾아보세요',
                style: TextStyle(
                  fontSize: 16,
                  color: SemanticColors.text.secondary,
                ),
              ),
              SizedBox(height: screenHeight * 0.15),
              _buildKakaoLoginButton(context, ref, isLoading),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKakaoLoginButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: SemanticColors.button.kakao,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SemanticColors.button.kakaoBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: SemanticColors.overlay.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                final success = await ref
                    .read(authNotifierProvider.notifier)
                    .loginWithKakao();
                if (success && context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: SemanticColors.special.transparent,
          shadowColor: SemanticColors.special.transparent,
          foregroundColor: SemanticColors.button.kakaoText,
          disabledBackgroundColor: SemanticColors.special.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(SemanticColors.text.disabled),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/kakao_icon.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.chat_bubble,
                        color: SemanticColors.button.kakaoText,
                        size: 24,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '카카오로 시작하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
