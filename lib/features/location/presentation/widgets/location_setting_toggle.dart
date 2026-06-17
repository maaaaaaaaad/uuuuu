import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

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
    if (state.isEnabled) {
      return '주변 뷰티샵 검색에 활용됩니다';
    }
    if (state.permissionStatus == LocationPermissionResult.deniedForever ||
        state.permissionStatus == LocationPermissionResult.denied) {
      return '디바이스 설정에서 위치 권한을 변경할 수 있어요';
    }
    return '현재 위치 기능을 사용하지 않습니다';
  }

  Future<void> _handleToggle(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(locationSettingNotifierProvider.notifier)
        .toggle();
    if (!context.mounted) return;
    if (result == LocationSettingToggleResult.deniedForever ||
        result == LocationSettingToggleResult.denied ||
        result == LocationSettingToggleResult.serviceDisabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('디바이스 설정에서 위치 권한을 변경할 수 있어요'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
