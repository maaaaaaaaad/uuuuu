import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

enum ValidationType { error, success, warning, info }

class ValidationMessage extends StatelessWidget {
  final String? message;
  final ValidationType type;

  const ValidationMessage({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(_getIcon(), size: 16, color: _getColor(context)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(fontSize: 12, color: _getColor(context)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case ValidationType.error:
        return Icons.error_outline;
      case ValidationType.success:
        return Icons.check_circle_outline;
      case ValidationType.warning:
        return Icons.warning_amber_outlined;
      case ValidationType.info:
        return Icons.info_outline;
    }
  }

  Color _getColor(BuildContext context) {
    switch (type) {
      case ValidationType.error:
        return SemanticColors.state.error;
      case ValidationType.success:
        return SemanticColors.state.success;
      case ValidationType.warning:
        return SemanticColors.state.warning;
      case ValidationType.info:
        return SemanticColors.state.info;
    }
  }
}
