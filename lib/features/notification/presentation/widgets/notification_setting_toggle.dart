import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/notification/presentation/providers/notification_setting_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/app_bottom_sheet.dart';

class NotificationSettingToggle extends ConsumerStatefulWidget {
  const NotificationSettingToggle({super.key});

  @override
  ConsumerState<NotificationSettingToggle> createState() =>
      _NotificationSettingToggleState();
}

class _NotificationSettingToggleState
    extends ConsumerState<NotificationSettingToggle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationSettingNotifierProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingAsync = ref.watch(notificationSettingNotifierProvider);

    return settingAsync.when(
      loading: _buildLoadingState,
      error: (error, stack) => _buildErrorState(),
      data: (state) => _buildToggle(context, ref, state),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '예약 알림 받기',
            style: TextStyle(fontSize: 16, color: SemanticColors.text.primary),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SemanticColors.indicator.loadingPink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '예약 알림 받기',
            style: TextStyle(fontSize: 16, color: SemanticColors.text.primary),
          ),
          Icon(Icons.error_outline, color: SemanticColors.state.error),
        ],
      ),
    );
  }

  Widget _buildToggle(
    BuildContext context,
    WidgetRef ref,
    NotificationSettingState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '예약 알림 받기',
                style: TextStyle(
                  fontSize: 16,
                  color: SemanticColors.text.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.isEnabled ? '예약 확정·임박 안내를 받습니다' : '예약 알림이 꺼져 있습니다',
                style: TextStyle(
                  fontSize: 12,
                  color: SemanticColors.text.secondary,
                ),
              ),
            ],
          ),
          Switch(
            value: state.isEnabled,
            onChanged: (_) => _handleToggle(context, ref),
            activeTrackColor: SemanticColors.button.primary.withValues(
              alpha: 0.5,
            ),
            activeThumbColor: SemanticColors.button.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggle(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(notificationSettingNotifierProvider.notifier)
        .toggle();

    if (!context.mounted) return;

    if (result == NotificationToggleResult.deniedForever ||
        result == NotificationToggleResult.denied) {
      _showSettingsDialog(context, ref);
    }
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showAppDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 권한 필요'),
        content: const Text('예약 알림을 받으려면 디바이스 설정에서 알림을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '닫기',
              style: TextStyle(color: SemanticColors.text.secondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(notificationSettingNotifierProvider.notifier)
                  .goToAppSettings();
            },
            child: Text(
              '설정으로 이동',
              style: TextStyle(color: SemanticColors.button.textButtonPink),
            ),
          ),
        ],
      ),
    );
  }
}
