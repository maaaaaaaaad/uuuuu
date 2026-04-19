import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:jellomark/features/location/presentation/widgets/location_setting_toggle.dart';
import 'package:jellomark/features/member/presentation/pages/withdrawal_page.dart';
import 'package:jellomark/features/member/presentation/providers/member_providers.dart';
import 'package:jellomark/features/recent_shops/presentation/pages/recent_shops_page.dart';
import 'package:jellomark/features/reservation/presentation/pages/my_reservations_page.dart';
import 'package:jellomark/features/reservation/presentation/pages/pending_reviews_page.dart';
import 'package:jellomark/features/reservation/presentation/providers/pending_review_provider.dart';
import 'package:jellomark/features/review/presentation/pages/my_reviews_page.dart';
import 'package:jellomark/features/usage_history/presentation/pages/usage_history_page.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/widgets/gradient_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: SemanticColors.icon.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: SemanticColors.text.primary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: SemanticColors.icon.secondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuItemWithBadge({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int badgeCount,
  }) {
    return ListTile(
      leading: Icon(icon, color: SemanticColors.icon.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: SemanticColors.text.primary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: SemanticColors.state.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: SemanticColors.text.onDark,
                ),
              ),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: SemanticColors.icon.secondary),
        ],
      ),
      onTap: onTap,
    );
  }

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
    final pendingCount = ref.watch(pendingReviewCountProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('프로필'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: SemanticColors.background.appBar,
        foregroundColor: SemanticColors.text.primary,
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
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: SemanticColors.background.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SemanticColors.border.glass),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.event_note_outlined,
                          title: '예약 현황',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MyReservationsPage(),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: SemanticColors.border.glass,
                        ),
                        _buildMenuItem(
                          icon: Icons.rate_review_outlined,
                          title: '내가 쓴 리뷰',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MyReviewsPage(),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: SemanticColors.border.glass,
                        ),
                        _buildMenuItemWithBadge(
                          icon: Icons.pending_actions_outlined,
                          title: '리뷰 작성 대기',
                          badgeCount: pendingCount,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PendingReviewsPage(),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: SemanticColors.border.glass,
                        ),
                        _buildMenuItem(
                          icon: Icons.receipt_long_outlined,
                          title: '이용기록',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const UsageHistoryPage(),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: SemanticColors.border.glass,
                        ),
                        _buildMenuItem(
                          icon: Icons.history,
                          title: '최근 본 샵',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RecentShopsPage(),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: SemanticColors.border.glass,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: LocationSettingToggle(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WithdrawalPage(),
                        ),
                      );
                    },
                    child: Text(
                      '회원 탈퇴',
                      style: TextStyle(
                        fontSize: 12,
                        color: SemanticColors.text.secondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
