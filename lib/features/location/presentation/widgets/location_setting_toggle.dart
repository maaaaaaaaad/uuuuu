import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/app_bottom_sheet.dart';

class LocationSettingToggle extends ConsumerStatefulWidget {
  const LocationSettingToggle({super.key});

  @override
  ConsumerState<LocationSettingToggle> createState() =>
      _LocationSettingToggleState();
}

class _LocationSettingToggleState extends ConsumerState<LocationSettingToggle>
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
      ref.read(locationSettingNotifierProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingAsync = ref.watch(locationSettingNotifierProvider);

    return settingAsync.when(
      loading: () => _buildLoadingState(),
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
            '위치 정보 사용',
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
            '위치 정보 사용',
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
    LocationSettingState state,
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
                '위치 정보 사용',
                style: TextStyle(
                  fontSize: 16,
                  color: SemanticColors.text.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getStatusText(state),
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

  String _getStatusText(LocationSettingState state) {
    if (!state.isEnabled) {
      return '현재 위치 기능을 사용하지 않습니다';
    }
    return '주변 뷰티샵 검색에 활용됩니다';
  }

  Future<void> _handleToggle(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(locationSettingNotifierProvider.notifier)
        .toggle();

    if (!context.mounted) return;

    if (result == LocationSettingToggleResult.deniedForever) {
      _showSettingsDialog(context, ref);
    }
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showAppDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한 필요'),
        content: const Text('위치 정보를 사용하려면 설정에서 위치 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(color: SemanticColors.text.secondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(locationSettingNotifierProvider.notifier)
                  .openAppSettings();
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
