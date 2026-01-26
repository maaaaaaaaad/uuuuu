import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class LocationPermissionAlertDialog {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onAgree,
    required VoidCallback onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: SemanticColors.overlay.dialogBarrier,
      builder: (context) => _LocationPermissionAlertContent(
        onAgree: onAgree,
        onCancel: onCancel,
      ),
    );
  }
}

class _LocationPermissionAlertContent extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback onCancel;

  const _LocationPermissionAlertContent({
    required this.onAgree,
    required this.onCancel,
  });

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
        Icons.location_on,
        size: 32,
        color: AppColors.pastelPink,
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      '젤로마크는 위치 기반 서비스이므로 위치 정보 제공에 동의가 꼭 필요해요',
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
          child: _CancelButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AgreeButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAgree();
            },
          ),
        ),
      ],
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CancelButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
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
    );
  }
}

class _AgreeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AgreeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
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
          '동의',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
