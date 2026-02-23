import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionDialog {
  static Future<void> show({required BuildContext context}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: SemanticColors.overlay.dialogBarrier,
      builder: (context) => const _NotificationPermissionContent(),
    );
  }
}

class _NotificationPermissionContent extends StatelessWidget {
  const _NotificationPermissionContent();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SemanticColors.special.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: SemanticColors.background.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: SemanticColors.border.glass,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 16),
            _buildMessage(),
            const SizedBox(height: 24),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.pastelPink.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications_active,
        size: 32,
        color: AppColors.pastelPink,
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      '예약 알림을 받으려면 알림 권한이 필요해요',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: SemanticColors.text.primary,
        height: 1.5,
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: SemanticColors.text.secondary,
                side: BorderSide(color: SemanticColors.border.secondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pastelPink,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppColors.pastelPink.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '설정으로 이동',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
