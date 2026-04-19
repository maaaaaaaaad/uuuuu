import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:jellomark/features/member/presentation/providers/withdrawal_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class WithdrawalPage extends ConsumerStatefulWidget {
  const WithdrawalPage({super.key});

  @override
  ConsumerState<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends ConsumerState<WithdrawalPage> {
  final PageController _pageController = PageController();
  final TextEditingController _confirmController = TextEditingController();

  static const List<String> _reasons = [
    '원하는 샵이 없어요',
    '자주 사용하지 않아요',
    '앱 사용이 불편해요',
    '개인정보 보호가 걱정돼요',
    '다른 서비스를 이용할 예정이에요',
    '이용이 만족스럽지 않았어요',
    '기타',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int page) async {
    ref.read(withdrawalProvider.notifier).goToStep(page);
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleReAuthAndSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('정말 탈퇴하시겠어요?'),
        content: const Text(
          '탈퇴하면 모든 데이터가 삭제되며\n복구할 수 없습니다.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: SemanticColors.state.error,
            ),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final reAuthResult = await ref.read(loginWithKakaoUseCaseProvider).call();
    final reAuthFailed = reAuthResult.isLeft();
    if (reAuthFailed) {
      messenger.showSnackBar(
        const SnackBar(content: Text('카카오 재인증에 실패했습니다')),
      );
      return;
    }

    final success = await ref.read(withdrawalProvider.notifier).submit();

    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('회원 탈퇴가 완료되었습니다')));
      navigator.pushNamedAndRemoveUntil('/login', (_) => false);
    } else {
      final message = ref.read(withdrawalProvider).errorMessage ?? '탈퇴에 실패했습니다';
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawalProvider);

    return Scaffold(
      backgroundColor: SemanticColors.background.card,
      appBar: AppBar(
        title: const Text('회원 탈퇴'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: SemanticColors.background.appBar,
        foregroundColor: SemanticColors.text.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (state.step > 0) {
              _goToPage(state.step - 1);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (state.step + 1) / 5,
            backgroundColor: SemanticColors.border.glass,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNoticeStep(),
                _buildReasonStep(state),
                _buildAgreementStep(state),
                _buildConfirmTextStep(state),
                _buildReAuthStep(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '회원 탈퇴 시 삭제되는 정보',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 24),
          _noticeItem('프로필 및 계정 정보'),
          _noticeItem('모든 예약 내역 (진행 중 포함)'),
          _noticeItem('작성한 리뷰 및 평점'),
          _noticeItem('즐겨찾기 및 이용기록'),
          _noticeItem('카카오 로그인 연동 정보'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SemanticColors.state.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '탈퇴 후 삭제된 데이터는 복구할 수 없으며,\n30일 내 동일 계정으로 재가입 시 이전 데이터가 복구되지 않습니다.',
              style: TextStyle(
                fontSize: 13,
                color: SemanticColors.state.error,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _goToPage(1),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticeItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.remove_circle_outline, color: SemanticColors.state.error, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildReasonStep(WithdrawalState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '탈퇴 사유를 알려주세요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '서비스 개선에 참고하겠습니다.',
            style: TextStyle(
              fontSize: 14,
              color: SemanticColors.text.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _reasons.length,
              itemBuilder: (ctx, i) {
                final reason = _reasons[i];
                final selected = state.selectedReason == reason;
                return InkWell(
                  onTap: () => ref
                      .read(withdrawalProvider.notifier)
                      .selectReason(reason),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected
                              ? SemanticColors.state.error
                              : SemanticColors.icon.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(reason)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.selectedReason != null
                  ? () => _goToPage(2)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementStep(WithdrawalState state) {
    const items = [
      '모든 데이터가 즉시 삭제됨을 이해했습니다',
      '진행 중 예약이 모두 취소됨을 이해했습니다',
      '작성한 리뷰는 "탈퇴한 회원"으로 표기됨을 이해했습니다',
      '삭제된 데이터는 복구할 수 없음을 이해했습니다',
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주의사항 확인',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(items.length, (i) {
            return CheckboxListTile(
              value: state.agreements[i],
              title: Text(items[i], style: const TextStyle(fontSize: 14)),
              onChanged: (_) =>
                  ref.read(withdrawalProvider.notifier).toggleAgreement(i),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.allAgreed ? () => _goToPage(3) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmTextStep(WithdrawalState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '확인 문구 입력',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text('아래 문구를 정확히 입력해주세요:'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SemanticColors.background.input,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '회원탈퇴에 동의합니다',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            onChanged: (v) =>
                ref.read(withdrawalProvider.notifier).updateConfirmText(v),
            decoration: const InputDecoration(
              hintText: '위 문구를 그대로 입력',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.confirmTextValid ? () => _goToPage(4) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReAuthStep(WithdrawalState state) {
    final submitting = state.status == WithdrawalStatus.submitting;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '본인 확인',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '마지막으로 카카오 재인증 후 탈퇴를 완료합니다.\n아래 버튼을 누르면 카카오 인증이 진행됩니다.',
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitting ? null : _handleReAuthAndSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: SemanticColors.state.error,
                foregroundColor: SemanticColors.text.onDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('카카오 재인증 후 탈퇴'),
            ),
          ),
        ],
      ),
    );
  }
}
