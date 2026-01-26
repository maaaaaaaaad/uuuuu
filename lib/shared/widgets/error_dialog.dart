import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ErrorDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '확인',
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: SemanticColors.overlay.dialogBarrier,
      builder: (context) => Dialog(
        backgroundColor: SemanticColors.special.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: SemanticColors.background.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SemanticColors.border.glass, width: 1.5),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: SemanticColors.state.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: SemanticColors.icon.primary,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm?.call();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: SemanticColors.button.textButton,
                  ),
                  child: Text(confirmText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
